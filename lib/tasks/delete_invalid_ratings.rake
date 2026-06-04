namespace :frab do
  desc 'Delete invalid rating records (out-of-range values). Use dry_run=1 to preview.'
  task delete_invalid_ratings: :environment do
    dry_run = ENV['dry_run'].present?

    invalid_feedbacks = EventFeedback.where('rating IS NOT NULL AND (rating < 1 OR rating > 5)')
    invalid_event_ratings = EventRating.where('rating < 0 OR rating > 5')
    invalid_review_scores = ReviewScore.where('score < 0 OR score > 5')

    puts "Invalid EventFeedback records: #{invalid_feedbacks.count}"
    puts "Invalid EventRating records: #{invalid_event_ratings.count}"
    puts "Invalid ReviewScore records: #{invalid_review_scores.count}"

    if dry_run
      puts 'Dry run — no records deleted.'
    else
      invalid_feedbacks.destroy_all
      invalid_event_ratings.destroy_all
      invalid_review_scores.destroy_all
      puts 'Deleted.'
    end
  end
end
