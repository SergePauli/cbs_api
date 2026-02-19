# CBS_API

API на RoR для новой версии "Контракты и контрагенты"  


* Ruby version 2.7.3

* System dependencies   
   

* Configuration
    
    bundle install   

    # JWT config for inter-service auth
    AUTH_JWT_ISSUER=cbs_api
    AUTH_JWT_AUDIENCE=cbs_api,files_api,billing_api
    AUTH_JWT_HMAC_SECRET=shared_hmac_secret
    AUTH_JWT_CLOCK_SKEW_SEC=30
    # one origin:
    # CORS_ALLOW_ORIGIN=http://localhost:3000
    # or CSV list:
    CORS_ALLOW_ORIGIN=http://cbs:3000,http://192.168.0.3:3000
    

* Database creation
  
    rails db:create RAILS_ENV=development (test, production)

* Database initialization

    rails db:migrate RAILS_ENV=development (test, production)
    rails db:seed RAILS_ENV=development (test, production)

* How to run the test suite
  
    bundle exec rspec

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
