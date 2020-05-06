module Adhoq
  class Execution < ActiveRecord::Base
    include Adhoq::TimeBasedOrders

    belongs_to :query
    has_one    :report, dependent: :destroy, inverse_of: :execution

    delegate   :supported_formats, to: Adhoq::Reporter

    def generate_report!
      build_report.generate!
      update!(status: :success)
    rescue StandardError => e
      Rails.logger.error(e)
      self.report = nil
      update!(status: :failure)
    end

    def name
      [query.slug, created_at.strftime('%Y%m%d-%H%M%S'), report_format].join('.')
    end

    def success?
      report.try(:available?) || status == 'success'
    end
  end
end
