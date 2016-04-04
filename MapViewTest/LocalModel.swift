//
//  LocalModel.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/4/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation

struct LocalModel
{
    var imageName: String
    var modelTitle: String

    init (name: String, title: String)
    {
        self.imageName = name
        self.modelTitle = title
    }
}


struct LocalModels
{
    let localModels =
    [
        LocalModel (name: "models_all", title: "All vehicle types"),
        LocalModel (name: "model_1", title: "Lincoln MKS"),
        LocalModel (name: "model_2", title: "Honda Civic"),
        LocalModel (name: "model_3", title: "Nissan Sentra"),
        LocalModel (name: "model_4", title: "Ford Transit Connect"),
        LocalModel (name: "model_5", title: "Mercedes-Benz GLK"),
        LocalModel (name: "model_6", title: "Subaru Crosstrek AWD with Ski Rack"),
        LocalModel (name: "model_7", title: "Subaru Crosstrek AWD"),
        LocalModel (name: "model_8", title: "Mazda 3"),
        LocalModel (name: "model_9", title: "Ford Focus Sedan"),
        LocalModel (name: "model_10", title: "Honda CR-V"),
        LocalModel (name: "model_11", title: "Subaru Impreza 5-door"),
        LocalModel (name: "model_12", title: "Honda Odyssey"),
        LocalModel (name: "model_13", title: "Nissan Sentra"),
        LocalModel (name: "model_14", title: "MINI Cooper Countryman"),
        LocalModel (name: "model_15", title: "Kia Forte")
    ]

    private static let database: Dictionary<String, LocalModel> =
        {
            var theDatabase = Dictionary<String, LocalModel>()
            var i = 1

            for model in LocalModels().localModels
            {
                theDatabase[i++] = model
            }
    }
}