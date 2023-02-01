require "rails_helper"

RSpec.describe "Model::Universals", type: :request do
  fixtures :users, :people, :contacts, :positions, :contragents

  let (:test_user) {
    REDIS.del "tokens"
    users(:admin)
  }
  let (:test_person) {
    users(:admin).person
  }

  let (:tokens) {
    dto = { id: test_user.id, email: test_user.email, role: test_user.role, logged: test_user.last_login }
    tokens = JsonWebToken.new_tokens(dto)
    REDIS.hset "tokens", tokens[:refresh], dto[:id]
    cookies[:refresh_token] = { value: tokens[:refresh], expires: JsonWebToken::LIFETIME.hour, httponly: true }
    tokens
  }

  let (:headers) {
    { "ACCEPT" => "application/json", "Authorization" => "Bearer #{tokens[:access]}" }
  }

  describe "POST model/Person" do
    it "должен возвращать список записей с набором данных для пунтка меню" do
      post "/model/Person", params: { data_set: "item" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include test_person.head
    end
    it "должен возвращать список записей с набором данных карточка" do
      post "/model/Person", params: { data_set: "card" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include test_person.card.to_json
    end
    it "должен возвращать только  2 и 3-э записи (пагинация) " do
      post "/model/Person", params: { data_set: "item", offset: 1, limit: 2 }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include test_person.item.to_json
    end
    it "должен возвращать количество записей" do
      post "/model/Person", params: { count: "1" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq people.count.to_s
    end
    it "должен возвращать запись удовлетворяющую параметру фильтрации" do
      post "/model/Person", params: { q: { person_names_naming_surname_eq: test_person.naming.surname }, data_set: "item", offset: 0, limit: 2 }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include test_person.item.to_json
    end
  end
  describe "GET model/Person" do
    it "должен возвращать запись удовлетворяющую с заданым id и набором данных" do
      get "/model/Person?id=#{test_person.id}&data_set=card", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include test_person.card.to_json
    end
    it "должен возвращать ошибку :bad_request, если параметр ID отсутствует" do
      get "/model/Person?data_set=card", headers: headers
      expect(response).to have_http_status(:bad_request)
    end
    it "должен возвращать ошибку :not_found, если ID не найден" do
      get "/model/Person?id=45699&data_set=card", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
  describe "POST model/add/:model_name" do
    it "должен возвращать добавленную запись и статус :ok" do
      post "/model/add/Person", params: { Person: { person_contacts_attributes: [{ contact_attributes: { value: "test@mail.ru", type: "Email" }, used: true }], person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] }, data_set: "card" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include "test@mail.ru"
    end
    it "должен возвращать ошибку :unprocessable_entity, если не указан ни один из контактов" do
      post "/model/add/Person", params: { Person: { person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] }, data_set: "card" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe "PUT model/:model_name/:id" do
    it "должен измененную запись и статус :ok" do
      put "/model/Person/1", params: { Person: { person_contacts_attributes: [{ contact_attributes: { value: "test2@mail.ru", type: "Email" }, used: true }] }, data_set: "card" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include "test2@mail.ru"
    end
    it "должен возвращать ошибку :bad_request, если не указаны параметры изменения модели" do
      put "/model/Person/1", params: { data_set: "card" }, headers: headers
      expect(response).to have_http_status(:bad_request)
    end
  end
  describe "DELETE model/:model_name/:id" do
    it "должен удалить запись, вернуть удаленную запись и статус :ok" do
      delete "/model/Contact/#{contacts(:some_mail).id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include contacts(:some_mail).value
      expect { contacts(:some_mail).reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "должен возвращать ошибку :unprocessable_entity, при попытке удаления связанной записи" do
      delete "/model/Person/1", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  # модели с аудитом изменений
  describe "POST model/add/Employee" do
    it "должен возвращать добавленную запись с автоматически сгенерированой информацией о добавлении и статус :ok" do
      post "/model/add/Employee", params: { Employee: { contragent_id: contragents(:kraskom).id, position_id: positions(:specialist).id, person_attributes: { person_contacts_attributes: [{ contact_attributes: { value: "test400@mail.ru", type: "Email" }, used: true }], person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] } }, data_set: "card" }, headers: headers
      expect(Audit.count).to eq 2
      expect(response).to have_http_status(:ok)
      expect(response.body).to include "test400@mail.ru"
      expect(response.body).to include "Аполонов Апалон Григорьевич"
      expect(response.body).to include "Добавлен: сотрудник"
    end

    it "должен возвращать ошибку :unprocessable_entity, записей аудита не должно создаваться" do
      post "/model/add/Employee", params: { Employee: { contragent_id: 999, position_id: positions(:specialist).id, person_attributes: { person_contacts_attributes: [{ contact_attributes: { value: "test400@mail.ru", type: "Email" }, used: true }], person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] } }, data_set: "card" }, headers: headers
      expect(Audit.count).to eq 0
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include "Не присвоен КОНТРАГЕНТ"
    end
  end
end
