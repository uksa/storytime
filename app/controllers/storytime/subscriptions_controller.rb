require_dependency "storytime/application_controller"

module Storytime
  class SubscriptionsController < ApplicationController
    before_action :set_subscription, only: [:destroy]

    def create
      @subscription = Storytime::Subscription.find_by(permitted_attributes) || Storytime::Subscription.new(permitted_attributes)
      @subscription.site = Storytime::Site.first if @subscription.site.nil? # if we ever go multi-site, this would likely become current_site
      @subscription.subscribed = true if @subscription.subscribed == false

      if @subscription.save
        flash[:notice] = I18n.t('flash.subscriptions.create.success')
      else
        flash[:error] = I18n.t('flash.subscriptions.create.fail')
      end

      redirect_to :back
    end

    def destroy
      if params[:t] == @subscription.token
        flash[:notice] = I18n.t('flash.subscriptions.destroy.success') if @subscription.unsubscribe!
      else
        flash[:error] = I18n.t('flash.subscriptions.destroy.fail')
      end

      redirect_to Storytime.home_page_path
    end

    private

      def permitted_attributes
        params.require(:subscription).permit(:email, :t)
      end

      def set_subscription
        @subscription = Storytime::Subscription.find_by(email: params[:email])
      end
  end
end
