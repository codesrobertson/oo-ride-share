require 'pry'

require_relative 'csv_record'

module RideShare
  class Driver < CsvRecord
    VIN_LEN = 17
    STATUSES = [:AVAILABLE, :UNAVAILABLE]
    TRIP_FEE = 1.65
    REVENUE_SHARE = 0.8

    attr_reader :id, :name, :vin, :status, :trips 

    def initialize(id:, name:, vin:, status: :AVAILABLE, trips: nil)
      super(id)

      @name = name
      @vin = vin
      if vin.length < 17 || vin.length > 17
        raise ArgumentError.new("Vin number wrong length. Please try again with a 17-character vin number.")
      end
      @status = status 
      if !STATUSES.include?(status)
        raise ArgumentError.new("Invalid entry for driver status: #{status}. Please try again with a valid entry, such as ':AVAILABLE' or ':UNAVAILABLE'.")
      end
      @trips = trips || []
    end 

    def start_trip(trip)
      add_trip(trip)
      @status = :UNAVAILABLE
    end

    def add_trip(trip)
      @trips << trip
    end  

    def average_rating
      average_rating = []
      @trips.each do |trip|
        average_rating << trip.rating.to_f 
      end
      if average_rating.empty?
        return 0
      end
      average_rating.sum / average_rating.length 
    end

    def total_revenue
      if trips.length == 0
        return 0
      elsif trips.length == 1 && !trips.first.rating
        return 0
      else
        gross_revenue = trips.reduce(0) do |total, trip|
        trip.cost ? (total + trip.cost.to_f) : total
      end
    end

    fees = (trips.count { |trip| (trip.cost && trip.cost >= 1.65) } * 1.65) +
    (trips.reduce(0) { |total, trip| (trip.cost && trip.cost < 1.65) ? (total + trip.cost.to_f) : total })
    total_revenue = (gross_revenue.to_f - fees) * 0.8
    return total_revenue.round(2)
    end

    def self.from_csv(record)
     return new(
       id:record[:id],
       name:record[:name],
       vin:record[:vin],
       status:record[:status].to_sym
      )
    end
  end 
end