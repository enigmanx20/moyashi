class AnalysisController < MoyashiAnalysisController

  define_params :pca, {pcx: :integer, pcy: :integer, file1: :file, file2: :file}

  def pca
  end
end



module MoyashiController

  PARAMS_TYPES = %i[integer float string text file]



  module ClassMethods
    def define_params(name, params)
      name = name.to_s + "_show"
      define_method name do
        raise 'Invalid parameter type' unless valid_params_type?(params)
        @_moyashi_show_params = params
      end
    end



    private
      def valid_params_type?(params)
        flg = true

        params.values do |v|
          unless PARAMS_TYPES.include?(v.to_sym)
            flg = false
            break
          end
        end

        flg
      end
  end



  def self.included(base)
    base.extend ClassMethods
  end
end



class MoyashiAnalysisController < ApplicationController
  include MoyashiController
end





