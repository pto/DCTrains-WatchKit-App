//
//  ComplicationController.swift
//  WatchDemo WatchKit Extension
//
//  Created by Peter Olsen on 5/31/17.
//  Copyright © 2017 Peter Olsen. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        let template = getComplicationTemplate(for: complication)
        if let t = template {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: t)
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let template = getComplicationTemplate(for: complication)
        if let t = template {
            handler(t)
        } else {
            handler(nil)
        }
    }

    func getComplicationTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {
        switch complication.family {
        case .circularSmall:
            let image = UIImage(named: "Complication/Circular")
            let imageProvider = CLKImageProvider(onePieceImage: image!)
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            template.imageProvider = imageProvider
            return template
        case .modularSmall:
            let image = UIImage(named: "Complication/Modular")
            let imageProvider = CLKImageProvider(onePieceImage: image!)
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = imageProvider
            return template
        case .extraLarge:
            let image = UIImage(named: "Complication/Extra Large")
            let imageProvider = CLKImageProvider(onePieceImage: image!)
            let template = CLKComplicationTemplateExtraLargeSimpleImage()
            template.imageProvider = imageProvider
            return template
        case .utilitarianSmall:
            let image = UIImage(named: "Complication/Utilitarian")
            let imageProvider = CLKImageProvider(onePieceImage: image!)
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            template.imageProvider = imageProvider
            return template
        case .graphicCircular:
            let image = UIImage(named: "Complication/Graphic Circular")
            let imageProvider = CLKFullColorImageProvider(fullColorImage: image!)
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = imageProvider
            return template
        case .graphicCorner:
            let image = UIImage(named: "Complication/Graphic Corner")
            let imageProvider = CLKFullColorImageProvider(fullColorImage: image!)
            let template = CLKComplicationTemplateGraphicCornerCircularImage()
            template.imageProvider = imageProvider
            return template
        default:
            return nil
        }
    }
}
