class Operation

  def self.user_info(formated_data)
    user_id = formated_data[:user_id]
    @user = TEMPLATE.join(USER.where(id: user_id), template_id: :id).to_a

    #user_info = {name: user[0][:name], bonus: user[0][:bonus], user_id: user[0][:id], template_id: user[0][:template_id]}
    # {:name=>"Иван", :bonus=>0.9952e4, :user_id=>1, :template_id=>1}
  end

  def self.products_info(formated_data)
    positions = formated_data[:positions] 
    # [{:id=>1, :price=>100, :quantity=>3},{:id=>2, :price=>50, :quantity=>2}, {:id=>3, :price=>40, :quantity=>1},{:id=>4, :price=>150, :quantity=>2}]
   
    products_info = positions.map {|x| PRODUCT.where(id: x[:id]).to_a}
    # [{:id=>2, :type=>"increased_cashback", :value=>"10"}],[{:id=>3, :type=>"discount", :value=>"15"}],[{:id=>4, :type=>"noloyalty", :value=>nil}]]
    
    @arr = positions.each_with_object([]) do |i,m|
      products_info.each do |v|
        unless v.empty?
          m << i.merge!(v[0]) if i[:id] == v[0][:id]
        end
      end
    end
    # [
    #  {:id=>2, :price=>50, :quantity=>2, :name=>"Молоко", :type=>"increased_cashback", :value=>"10"},
    #  {:id=>3, :price=>40, :quantity=>1, :name=>"Хлеб", :type=>"discount", :value=>"15"},
    #  {:id=>4, :price=>150, :quantity=>2, :name=>"Сахар", :type=>"noloyalty", :value=>nil}
    # ]
  end

  def self.calculation_for_product(products)
    products.map do |i|
      i[:sum] = i[:price]*i[:quantity]*(i[:type] == "discount" ? (100 - i[:value].to_f)/100 : 1)
      i[:discount] = i[:price]*i[:quantity] - i[:sum]
      i[:cashback] = i[:sum]*(i[:type] == "increased_cashback" ? i[:value].to_f/100 : 0)
    end
    products 
    # [
    #  {:id=>2, :price=>50,:quantity=>2,:name=>"Молоко",:type=>"increased_cashback",:value=>"10",:sum=>100,:discount=>0,:cashback=>10.0},
    #  {:id=>3,:price=>40,:quantity=>1,:name=>"Хлеб",:type=>"discount",:value=>"15",:sum=>34.0,:discount=>6.0,:cashback=>0.0},
    #  {:id=>4,:price=>150,:quantity=>2,:name=>"Сахар",:type=>"noloyalty",:value=>nil,:sum=>300,:discount=>0,:cashback=>0}
    # ]
  end

  def self.total_calculation(products)
    total = {sum: 0, products_discount: 0, products_cashback: 0}

    products.map do |i|
      total[:sum]+= i[:sum]
      total[:products_discount]+= i[:discount]
      total[:products_cashback]+= i[:cashback]
    end

    us = @user[0].merge(total)
  # {
  #   :id=>1, :name=>"Иван", :discount=>0, :cashback=>5, :template_id=>1, :bonus=>9952.0, 
  #   :sum=>434.0, :products_discount=>6.0, :products_cashback=>10.0
  #  }

    tt = {}
    tt[:user_id] = us[:id]
    tt[:check_summ] = us[:sum]*(us[:discount] > 0 ? (100 - us[:discount])/100 : 1)
    tt[:discount] = us[:sum] - tt[:check_summ] + us[:products_discount]
    tt[:discount_percent] = (tt[:discount]/tt[:check_summ]*100).round(3)
    tt[:cashback] = us[:products_cashback] + (us[:cashback] > 0 ? tt[:check_summ]*us[:cashback].to_f/100 : 0)
    tt[:cashback_percent] = (tt[:cashback]/tt[:check_summ]*100).round(3)
    tt[:bonus] = us[:bonus]
    tt[:allowed_write_off] = tt[:bonus] >= tt[:check_summ] ? tt[:check_summ] : tt[:bonus]

    tt # {
       #  :user_id=>1, :check_summ=>434.0, :discount=>6.0, :discount_percent=>1.382, :cashback=>31.7,
       #  :cashback_percent=>7.304, :bonus=>0.9952e4, :allowed_write_off=>434.0
       # }
  end
end




