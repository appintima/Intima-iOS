//
//  CustomMGLAnnotation.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-13.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Mapbox

class CustomMGLAnnotation: MGLPointAnnotation{

    var job: Job?

    override init() {
        super.init()
        

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

