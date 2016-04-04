//
//  LocalStyles.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/4/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation

struct LocalStyle
{
    var imageName: String
    var styleTitle: String

    init (name: String, title: String)
    {
        self.imageName = name
        self.styleTitle = title
    }
}


struct LocalStyles
{
    let localStyles =
        [
            LocalStyle (name: "models_all", title: "All vehicle types"),
            LocalStyle (name: "model_1", title: "4-door"),
            LocalStyle (name: "model_2", title: "5-door"),
            LocalStyle (name: "model_3", title: "Cargo Van"),
            LocalStyle (name: "model_4", title: "Coupe"),
            LocalStyle (name: "model_5", title: "Hatchback"),
            LocalStyle (name: "model_6", title: "Hybrid"),
            LocalStyle (name: "model_7", title: "Luxury"),
            LocalStyle (name: "model_8", title: "Minivan"),
            LocalStyle (name: "model_9", title: "Sedan"),
            LocalStyle (name: "model_10", title: "SUV"),
            LocalStyle (name: "model_11", title: "Wagon")
    ]

    private static let database: Dictionary<String, LocalStyle> =
    {
        var theDatabase = Dictionary<String, LocalStyle>()
        var i = 1

        for style in LocalStyles().localStyles
        {
            theDatabase[i++] = style
        }
    }
}