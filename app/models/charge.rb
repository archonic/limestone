class Charge < ActiveRecord::Base
  belongs_to :user

  def receipt
    Receipts::Receipt.new(
      id: id,
      product: "Limestone",
      company: {
        name: "No One, Inc.",
        address: "123 Example St\nSuite 42\nNew York City, NY 10012",
        email: "support@example.com",
        logo: Rails.root.join("app/assets/images/logo.png")
      },
      line_items: [
        ["Date",           created_at.to_s],
        ["Account Billed", "#{user.name} (#{user.email})"],
        ["Product",        "Example Product"],
        ["Amount",         "$#{amount / 100}.00"],
        ["Charged to",     "#{card_type} (**** **** **** #{card_last4})"],
        #["Transaction ID", uuid]
      ]
      # ,
      # font: {
      #   bold: Rails.root.join('app/assets/fonts/tradegothic/TradeGothic-Bold.ttf'),
      #   normal: Rails.root.join('app/assets/fonts/tradegothic/TradeGothic.ttf'),
      # }
    )
  end
end
