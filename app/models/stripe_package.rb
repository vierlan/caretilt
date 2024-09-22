class StripePackage

  def initialize(package)
    @package = package
  end

  def create_package
    return if @package.stripe_id.present?
    Stripe.api_key = Rails.application.credentials.stripe[:api_key]
    stripe_product = Stripe::Product.create(
      name: @package.name,
      description: @package.description,
      active: true,
      metadata: {
        package_id: @package.id,
        credits: @package.credits,
        validity: @package.validity,
        created: Date.today.to_time.to_i
      }
    )
    stripe_price = Stripe::Price.create(
      currency: 'gbp',
      unit_amount_decimal: @package.price * 100,
      product: stripe_product.id
    )
    Stripe::Plan.create(
      amount: @package.price * 100,
      currency: 'gbp',
      interval: 'month',
      product: stripe_product.id,
      id: stripe_product.id,
      nickname: @package.name,
      usage_type: 'licensed',
      interval_count: 1
    )
    @package.update(
      stripe_id: stripe_product.id,
      data: stripe_product.to_json,
      stripe_price_id: stripe_price.id
    )

  end

  def update_package
    return if @package.stripe_id.blank?
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    cloudinary_base_url = 'https://res.cloudinary.com/drirqdfbt/image/upload/v1724362903/development/'
    if @package.photo.nil?
      raise "Package photo is missing"
    else
      puts @package.photo.key
      image_url_append = @package.photo.key
      Rails.logger.info "Updating Stripe product for package: #{@package} with photo: #{image_url_append}"
      image = "#{cloudinary_base_url}#{image_url_append}.jpg"
      stripe_product = Stripe::Product.retrieve(@package.stripe_id)
      stripe_product.name = @package.package_name
      stripe_product.description = @package.package_description
      stripe_product.images = [image]
      stripe_product.save
      stripe_price = Stripe::Price.retrieve(@package.stripe_price_id)
      stripe_price.unit_amount_decimal = @package.package_price * 100
      stripe_price.save
      @package.update(
        data: stripe_product.to_json
      )
    end
  end



end
