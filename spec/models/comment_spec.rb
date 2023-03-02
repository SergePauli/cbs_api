require "rails_helper"

RSpec.describe Comment, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # обеспечение полиморфной связи
  it { is_expected.to have_db_column(:commentable_id).of_type(:integer) }
  it { is_expected.to have_db_column(:commentable_type).of_type(:string) }

  it { is_expected.to belong_to(:commentable) }

  let (:new_comment) {
    Comment.new
  }

  it "должна быть невалидной при отсутствии :action в списке ошибок должно быть сообщение" do
    expect(new_comment).not_to be_valid
    expect(new_comment.errors[:content]).not_to be_nil
  end

  it "должна быть невалидной при отсутствии :profile в списке ошибок должно быть сообщение" do
    expect(new_comment).not_to be_valid
    expect(new_comment.errors[:profile]).not_to be_nil
  end

  fixtures :profiles, :contragents

  let (:comment) {
    Comment.new(commentable: contragents(:kraskom), content: "test comment", profile: profiles(:user))
  }

  it "должна быть валидной в случае штатных параметров" do
    expect(comment).to be_valid
  end

  it "должна штатно сздаваться (c запоминанием person_id пользователя), удаляться" do
    expect(comment.save).to eq true
    expect(comment.person_id).to eq profiles(:user).user.person_id
    expect(Comment.count).to eq 1
    comment.destroy
    expect(Comment.count).to eq 0
  end
end
