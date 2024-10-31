//
//  consult.js
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 31/10/24.
//

db.matches.aggregate([{
      $match: {
          "creation_date": {
              $gte: ISODate("2030-10-12")
          }
      }
  },
  {
      $group: {
          _id: { "destination": "$destination.name"},
          count: { $sum: 1 },
          latitude: { $first: "$destination.latitude" }
      }
  }])

