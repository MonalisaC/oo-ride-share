require 'csv'
require_relative 'trip'

module RideShare
  class Driver
    attr_reader :id, :name, :vehicle_id, :status, :trips

    def initialize(input)
      if input[:id] == nil || input[:id] <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{input[:id]})")
      end
      if input[:vin] == nil || input[:vin].length != 17
        raise ArgumentError.new("VIN cannot be less than 17 characters.  (got #{input[:vin]})")
      end

      @id = input[:id]
      @name = input[:name]
      @vehicle_id = input[:vin]
      @status = input[:status] == nil ? :AVAILABLE : input[:status]

      @trips = input[:trips] == nil ? [] : input[:trips]
    end

    def average_rating
      total_ratings = 0
      @trips.map{|trip|
        total_ratings += trip.rating if !trip.end_time.nil? }
        if trips.length == 0
          average = 0
        else
          average = (total_ratings.to_f) / trips.length
        end

        return average
      end

      def total_revenue
        # total_revenue = 0
        # @trips.each{ |each_trip|
        #   total_revenue += (each_trip.cost-1.65)* 0.8}
        # return total_revenue.round(2)
        return @trips.reduce(0) { |total, each_trip| total + (each_trip.end_time.nil? ? 0 : (each_trip.cost-1.65) * 0.8) }.round(2)
      end

      def average_revenue_per_hour
        total_duration = 0
        @trips.map{|each_trip|
          total_duration += each_trip.duration if !each_trip.end_time.nil? }
          return total_revenue / (total_duration / 3600)
        end

        def add_latest_trip trip
          @trips << trip
          @status = :UNAVAILABLE
        end

        def add_trip(trip)
          raise ArgumentError.new("Can only add trip instance to trip collection") if trip.class != Trip
          @trips << trip
        end

        def is_trip_in_progress?
          # return false if there is no trip
          return false if @trips.length == 0

          # else return true/false based on last trip end_time
          return @trips.last.end_time.nil?
        end

        def recent_trip_end_time
          return 0 if @trips.length == 0
          return @trips.sort_by{ |trip| trip.end_time.nil? ? 0 : trip.end_time.to_i }.last.end_time
        end

      end
    end
