Reference Data Integration Guide

Overview
This guide explains how the three additional JSON files enhance the flight booking app with rich, user-friendly information.

JSON Files Purpose
1. airline-list.json
Purpose: Provides airline details including real logos

Sample Data:

json
[
  {
    "AirLineCode": "HV",
    "AirLineName": "Transavia Airlines",
    "AirLineLogo": "https://travelnext.works/api/airlines/HV.gif"
  }
]
What it provides:

✅ Real airline logos (no need to generate them)
✅ Full airline names
✅ Consistent airline code mapping
2. extra-services.json
Purpose: Provides additional services, primarily baggage options

Sample Data:

json
{
  "ExtraServicesResponse": {
    "ExtraServicesResult": {
      "success": true,
      "ExtraServicesData": {
        "DynamicBaggage": [
          {
            "Behavior": "PER_PAX_OUTBOUND",
            "IsMultiSelect": false,
            "Services": [[
              {
                "ServiceId": "1",
                "CheckInType": "AIRPORT",
                "Description": "1 bags - 15Kg",
                "FareDescription": "The charges are added while making the ticket",
                "IsMandatory": false,
                "MinimumQuantity": 0,
                "MaximumQuantity": 3,
                "ServiceCost": {
                  "CurrencyCode": "USD",
                  "Amount": "51.92",
                  "DecimalPlaces": "2"
                }
              }
            ]]
          }
        ]
      }
    }
  }
}
What it provides:

✅ Baggage options with weights (15Kg, 20Kg, 25Kg)
✅ Pricing for additional baggage
✅ Quantity limits (min/max)
✅ Check-in type information
✅ Allows users to customize their booking
3. trip-details.json
Purpose: Example booking data showing passenger information

Sample Data:

json
{
  "TripDetailsResponse": {
    "TripDetailsResult": {
      "Success": "true",
      "Target": "Test",
      "TravelItinerary": {
        "BookingStatus": "Booked",
        "Destination": "STN",
        "FareType": "WebFare",
        "ItineraryInfo": {
          "CustomerInfos": [
            {
              "CustomerInfo": {
                "PassengerType": "ADT",
                "PassengerFirstName": "John",
                "PassengerLastName": "Doe",
                "PassengerTitle": "Mr",
                "eTicketNumber": "AHFYWJ",
                "DateOfBirth": "2004-10-30T00:00:00",
                "EmailAddress": "john2Doe@gmail.com",
                "PassengerNationality": "IN",
                "PassportNumber": "5467455",
                "PhoneNumber": "9847012345"
              }
            }
          ]
        }
      }
    }
  }
}
What it provides:

✅ Example of complete booking structure
✅ Passenger information format
✅ Booking confirmation details
✅ Template for booking confirmation screen
✅ E-ticket information

Architecture Integration
Data Flow
┌─────────────────────────────────────────────────────────┐
│                      App Startup                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│       ReferenceDataSource.loadAllReferenceData()        │
│                                                          │
│  Loads 3 JSON files:                                    │
│  1. airline-list.json    → Map<code, AirlineReference>  │
│  2. extra-services.json  → ExtraServicesResponse        │
│  3. trip-details.json    → TripDetailsResponse          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              FlightBloc loads flights                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│         EnrichFlights Use Case processes each flight    │
│                                                          │
│  Flight + ReferenceData = EnrichedFlight                │
│  {                                                       │
│    flight: Flight,                                      │
│    airlineDetails: AirlineReference,  ← from JSON       │
│    baggageOptions: [ServiceOption]    ← from JSON       │
│  }                                                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                 UI displays enriched data                │
│                                                          │
│  - Real airline logo                                    │
│  - Full airline name                                    │
│  - Baggage options available                            │
│  - Add baggage button                                   │
└─────────────────────────────────────────────────────────┘
