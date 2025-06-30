# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_28_052714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "disbursements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "merchant_id", null: false
    t.string "reference", null: false
    t.date "disbursed_on", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.decimal "total_fees", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_disbursements_on_merchant_id"
    t.index ["reference"], name: "index_disbursements_on_reference", unique: true
  end

  create_table "merchants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", null: false
    t.string "email", null: false
    t.date "live_on", null: false
    t.integer "disbursement_frequency", null: false
    t.decimal "minimum_monthly_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_id", null: false
    t.index ["reference"], name: "index_merchants_on_reference", unique: true
    t.index ["source_id"], name: "index_merchants_on_source_id", unique: true
  end

  create_table "monthly_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "merchant_id", null: false
    t.date "month", null: false
    t.decimal "total_commissions", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "fee_charged", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "month"], name: "index_monthly_fees_on_merchant_id_and_month", unique: true
    t.index ["merchant_id"], name: "index_monthly_fees_on_merchant_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "merchant_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "commission_fee", precision: 10, scale: 2
    t.uuid "disbursement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_id", null: false
    t.index ["disbursement_id"], name: "index_orders_on_disbursement_id"
    t.index ["merchant_id", "disbursement_id", "commission_fee", "created_at"], name: "index_orders_on_merchant_disbursement_fee_created_at"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["source_id"], name: "index_orders_on_source_id", unique: true
  end

  add_foreign_key "disbursements", "merchants"
  add_foreign_key "monthly_fees", "merchants"
  add_foreign_key "orders", "merchants"
end
