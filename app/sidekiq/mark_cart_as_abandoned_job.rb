class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    Cart.where('last_interaction_at <= ?', 3.hours.ago)
      .find_each(&:mark_as_abandoned)
    
    Cart.where('last_interaction_at <= ?', 7.days.ago)
      .find_each(&:destroy)
  end
end
