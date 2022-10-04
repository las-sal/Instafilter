//
//  FilterHandler.swift
//  Instafilter
//
//  Created by sal on 9/26/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins


//
// FilterInputType
//
// Enum to define what filter input parameters are supported in the app.
// Also stores the Core Image string keys needed to set those filters
// within the Core Image object.
//
enum FilterInputType: String {
    case intensity = "Intensity"
    case radius = "Radius"
    case scale = "Scale"
    
    func getKey() -> String {
        switch self {
            case .intensity:
                return kCIInputIntensityKey
            case .radius:
                return kCIInputRadiusKey
            case .scale:
                return kCIInputScaleKey
        }
    }
}

//
// FilterType
//
// Enum storing the Core Image filters supported by the app. The
// raw strings for each case correspond to the naming within the
// Core Image app and are appropriate to use for display. The
// enum also supports a function to provide which inputs are
// supported for a give filter and the range to be allowed for
// that input on that filter. The enum also provides an init
// function to allocate the Core Image instance of a filter
// corresponding to the case.
//
enum FilterType: String, CaseIterable {
    case crystallize = "Crystallize"
    case edges = "Edges"
    case gaussianBlur = "Gaussian Blur"
    case pixellate = "Pixellate"
    case sepiaTone = "Sepia Tone"
    case unsharpMask = "Unsharp Mask"
    case vignette = "Vignette"
    case none = ""
    
    //
    // inputType
    //
    // Returns inputs supported and the range for that input for the given filter.
    //
    func inputType() -> [(input: FilterInputType, range: ClosedRange<Double>)]? {
        switch self {
            case .crystallize:
                return [(.radius, 1.0...200.0)]
            case .edges:
                return [(.intensity, 0.0...1.0)]
            case .gaussianBlur:
                return [(.radius, 1.0...200.0)]
            case .pixellate:
                return [(.scale, 1.0...10.0)]
            case .sepiaTone:
                return [(.intensity, 0.0...1.0)]
            case .vignette:
                return [(.intensity, 0.0...2.0), (.radius, 1.0...200.0)]
            case .unsharpMask:
                return [(.intensity, 0.0...1.0), (.radius, 1.0...200.0)]
            case .none:
                return nil
        }
    }
    
    //
    // initFilter
    //
    // Allocates an instance of the given filter from Core Image and returns it.
    //
    func initFilter() -> CIFilter? {
        switch self {
            case .crystallize:
                return CIFilter.crystallize()
            case .edges:
                return CIFilter.edges()
            case .gaussianBlur:
                return CIFilter.gaussianBlur()
            case .pixellate:
                return CIFilter.pixellate()
            case .sepiaTone:
                return CIFilter.sepiaTone()
            case .vignette:
                return CIFilter.vignette()
            case .unsharpMask:
                return CIFilter.unsharpMask()
            case .none:
                return nil
        }
    }
    
    //
    // listOfFilters
    //
    // Returns an array of strings of the filter names.
    //
    static func listOfFilters(limit:Int? = nil) -> [String] {
        
        var allFilters: [String] = []
        
        let bounds = limit ?? FilterType.allCases.count
        
        for filter in FilterType.allCases[0...(bounds-1)] {
            allFilters.append(filter.rawValue)
        }
        
        return allFilters
    }
    
    //
    // listOfFilters
    //
    // Returns a count of filters.
    //
    static func numFilters() -> Int {
        FilterType.allCases.count
    }
}
