require_relative 'spec_helper'

describe "Driver class" do

  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(id: 1, name: "George", vin: "33133313331333133")
    end
    it "is an instance of Driver" do
      @driver.must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad ID value" do
      proc{ RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133")}.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      proc{ RideShare::Driver.new(id: 100, name: "George", vin: "")}.must_raise ArgumentError
      proc{ RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums")}.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      @driver.trips.must_be_kind_of Array
      @driver.trips.length.must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vehicle_id, :status].each do |prop|
        @driver.must_respond_to prop
      end

      @driver.id.must_be_kind_of Integer
      @driver.name.must_be_kind_of String
      @driver.vehicle_id.must_be_kind_of String
      @driver.status.must_be_kind_of Symbol
    end
  end

  describe "add trip method" do
    before do
      pass = RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640")
      @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
      @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: pass, start_time: Time.parse('2015-05-20T12:14:00+00:00'), end_time: Time.parse('2015-05-20T12:16:00+00:00'), rating: 5})
    end

    it "throws an argument error if trip is not provided" do
      proc{ @driver.add_trip(1) }.must_raise ArgumentError
    end

    it "increases the trip count by one" do
      previous = @driver.trips.length
      @driver.add_trip(@trip)
      @driver.trips.length.must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = Time.parse('2015-05-20T14:16:23+00:00')
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: start_time, end_time: end_time, rating: 5})
      @driver.add_trip(trip)
    end

    it "returns a float" do
      @driver.average_rating.must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      average.must_be :>=, 1.0
      average.must_be :<=, 5.0
    end

    it "returns zero if no trips" do
      driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      driver.average_rating.must_equal 0
    end
  end

  describe "#total_revenue" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = Time.parse('2015-05-20T14:16:23+00:00')
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: start_time, end_time: end_time,cost: 4, rating: 5})
      trip1 = RideShare::Trip.new({id: 8, driver: nil, passenger: @passenger, start_time: start_time, end_time: end_time, cost: 4.50, rating: 5})
      trip2_in_progress = RideShare::Trip.new({id: 10, driver: nil, passenger: @passenger, start_time: start_time, end_time: nil, cost: 35.34, rating: 5})

      @driver.add_trip(trip)
      @driver.add_trip(trip1)
      @driver.add_trip(trip2_in_progress)
    end
    it "returns driver's total revenue across all their trips and ignores in-progress trips" do
      @driver.total_revenue.must_equal 4.16
      @driver.total_revenue.must_be_instance_of Float
    end
  end

  describe "#average_revenue_per_hour" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = Time.parse('2015-05-20T14:16:23+00:00')
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
      trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: start_time, end_time: end_time,cost: 4, rating: 5})
      trip1 = RideShare::Trip.new({id: 8, driver: nil, passenger: @passenger, start_time: start_time, end_time: end_time, cost: 4.50, rating: 5})
      trip2_in_progress = RideShare::Trip.new({id: 10, driver: nil, passenger: @passenger, start_time: start_time, end_time: nil, cost: 35.34, rating: 5})

      @driver.add_trip(trip)
      @driver.add_trip(trip1)
      @driver.add_trip(trip2_in_progress)
    end
    it "returns the driver's average revenue per hour spent driving and ignores in-progress trips" do
      @driver.average_revenue_per_hour.must_equal 1.04
      @driver.average_revenue_per_hour.must_be_instance_of Float
    end

    describe "#is_trip_in_progress?" do
      before do
        start_time = Time.parse('2015-05-20T12:14:00+00:00')
        end_time = Time.parse('2015-05-20T14:16:23+00:00')
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
        @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: start_time, end_time: end_time,cost: 4, rating: 5})
        @trip1 = RideShare::Trip.new({id: 8, driver: nil, passenger: @passenger, start_time: start_time, end_time: end_time, cost: 4.50, rating: 5})
      end

      it "returns false if there are no trips" do
        @driver.is_trip_in_progress?.must_equal false
      end

      it "informs false if trip is not in progress" do
        @driver.add_trip(@trip)
        @driver.add_trip(@trip1)
        @driver.is_trip_in_progress?.must_equal false
      end

      it "informs true if trip is in progress" do
        @driver.add_trip(@trip)
        @driver.add_trip(@trip1)
        start_time = Time.parse('2015-05-20T12:14:00+00:00')
        trip2_in_progress = RideShare::Trip.new({id: 10, driver: nil, passenger: @passenger, start_time: start_time, end_time: nil, cost: 35.34, rating: 5})
        @driver.add_trip(trip2_in_progress)
        @driver.is_trip_in_progress?.must_equal true
      end
    end

    describe "#recent_trip_end_time" do
      before do
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
        @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: nil, start_time: Time.parse('2015-05-20T12:14:00+00:00'), end_time: Time.parse('2015-05-20T14:16:23+00:00'),cost: 4, rating: 5})
        @trip1 = RideShare::Trip.new({id: 8, driver: nil, passenger: @passenger, start_time: Time.parse('2015-05-20T14:30:00+00:00'), end_time: Time.parse('2015-05-20T15:00:00+00:00'), cost: 4.50, rating: 5})
      end

      it "returns false if there are no trips" do
        @driver.recent_trip_end_time.must_equal 0
      end

      it "returns most recent trip end time of driver" do
        @driver.add_trip(@trip)
        @driver.add_trip(@trip1)
        @driver.recent_trip_end_time.must_equal @trip1.end_time
      end
    end

  end
end
