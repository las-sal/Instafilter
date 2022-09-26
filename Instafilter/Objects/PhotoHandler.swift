//
//  PhotoImage.swift
//  Instafilter
//
//  Created by sal on 9/19/22. Encapulates core image setup and processing within instafilter.
//  This class handles the heavy lifting of the app as well as stores all data. It completely
//  separates the data from the view.
//
//  Given the several different image types, I put a tag on the end of each variable denoting
//  what it was _ci for CoreImage, _ui for UIImage, and nothing for Image. I found this very
//  helpful.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

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
    case none = "No Filter Input"
    
    func getKey() -> String {
        switch self {
            case .intensity:
                return kCIInputIntensityKey
            case .radius:
                return kCIInputRadiusKey
            case .scale:
                return kCIInputScaleKey
            case .none:
                return ""
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
enum FilterType: String {
    case crystallize = "Crystallize"
    case edges = "Edges"
    case gaussianBlur = "Gaussian Blur"
    case pixellate = "Pixellate"
    case sepiaTone = "Sepia Tone"
    case unsharpMask = "Unsharp Mask"
    case vignette = "Vignette"
    case none = "No Filter Set"
    
    //
    // inputType
    //
    // Returns inputs supported and the range for that input for the given filter.
    //
    func inputType() -> [(input: FilterInputType, range: ClosedRange<Double>)] {
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
                return [(.intensity, 0.0...1.0)]
        }
    }
    
    //
    // initFilter
    //
    // Allocates an instance of the given filter from Core Image and returns it.
    //
    func initFilter() -> CIFilter {
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
                return CIFilter.sepiaTone()
        }
    }
}

//
// FilterInput
//
// Helper class to track the state of a given filter input.
//
class FilterInput: ObservableObject {
    let name:String
    let range:ClosedRange<Double>
    let type:FilterInputType
    @Published var value:Double
    
    init(name: String, range: ClosedRange<Double>, type:FilterInputType, value:Double) {
        self.name = name
        self.range = range
        self.type = type
        self.value = value
    }
}

//
// PhotoHandler
//
// The main data store and handler for the app. Encapsulates all interactions
// with Core Image and UIKit. Handles loading and saving images. Handles
// instantiatino and configuring core image filters. Houses data for view
// to use. Store the filters we can use, the inputs on those filters that
// are supported, and the range for the input that we want to use on that
// particular image.
//
class PhotoHandler: ObservableObject {
    
    // Image selected from the Photo picker for the user's photo library.
    // We persist it here in case the user wants to save it. It contains
    // all processing applied to processedImage as it is used in the
    // the conversion from a core image.
    private var pickerImage_ui:UIImage? = nil
    
    // Image displayed in the main UI with filter effects applied
    private var processedImage_ui:UIImage? = nil
    
    // The main CoreImage filter. We are using CIFilter instead
    // of a specific filter type so we can hold different filters
    // in the same variable.
    private var filter_ci:CIFilter = CIFilter.sepiaTone()
    private(set) var filterType:FilterType = .sepiaTone
    
    @Published var filterInputs:[FilterInput] = []
    @Published var processedImage:Image? = nil
    
    // Expensive to allocate. Only allocate once.
    let ciContext = CIContext()
    
    // Will setup filter and inputs for .sepiatone
    init() {
        setFilter(.sepiaTone)
    }
    
    //
    // setFilter
    //
    // A new filter has been selected by the client. the filterInput dictionary
    // should be cleaned out so the correct filter inputs can be setup for the
    // new filter. The new filter is allocated (via the enum function) and the
    // type of filter is set.
    //
    // Leaving this function the filter has been setup but no filter inputs
    // have been configured (such as intensity, radius, or scale).
    //
    func setFilter(_ newFilterType:FilterType) {
        
        // Clear out old filter input info.
        filterInputs.removeAll()
        filterType = newFilterType
        filter_ci = newFilterType.initFilter()
        

        // Configure inputs supported by this filter.
        for inputTuple in filterType.inputType() {
                        
            print("configureInputs: Configuring input \(inputTuple.input.rawValue) with range \(inputTuple.range)")
            
            let filterInput = FilterInput(name: inputTuple.input.rawValue,
                                          range: inputTuple.range,
                                          type: inputTuple.input,
                                          value: (inputTuple.range.upperBound - inputTuple.range.lowerBound)/2 + inputTuple.range.lowerBound)
                
            filterInputs.append(filterInput)
            setFilterInputLevel(filterInput.type, value:filterInput.value)
        }
    }
    
    //
    // setFilterInputLevel
    //
    // Allows a caller to set the leven of the specified input type
    //
    func setFilterInputLevel(_ type:FilterInputType, value:Double) {
  
        filterInputs = filterInputs.map { input -> FilterInput in
            let newInput = input
            if input.type == type {
                newInput.value = value
            }
            return newInput
        }

        // A level has been changed, let's reprocess the image.
        loadAndProcessImage()
    }
    
    //
    // loadAndProcessImage
    //
    // Called when pickerImage_ui changes (via the ImagePicker view that allows
    // the user to select something from the photo library. When pickerImage_ui
    // changes (via a binding of it to ImagePIcker), then the loadImage func here
    // is called.
    //
    func loadAndProcessImage(_ pickerImage_ui:UIImage? = nil) {
        
        // If there is a new pickerImage, then load it into the member variable.
        // if not, then it will use the old.
        if let pickerImage_ui = pickerImage_ui {
            self.pickerImage_ui = pickerImage_ui
        }
        
        // Unwrap pickerImage_ui
        guard let pickerImage_ui = self.pickerImage_ui else { return }
        
        // Convert the selected UIImage to a CIImage - which is the only thing
        // CoreImage can process.
        let pickerImage_ci = CIImage(image: pickerImage_ui)
        
        // I guess this stores the image in the filter identified by an inputkey
        filter_ci.setValue(pickerImage_ci, forKey: kCIInputImageKey)
        
        //
        // This worked when currentFilter was a CISepiaTone. When we moved to using
        // CIFilter, we had to fall back to the generic way of setting keyValues.
        //
        //currentFilter.intensity = Float(filterIntensity)
        
        //
        // This worked when we were only using the sepia filter. replace
        // with something more generic
        //
        //currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        
        
        for input in filterInputs {
            
            if filter_ci.inputKeys.contains(input.type.getKey()) {
                filter_ci.setValue(input.value, forKey: input.type.getKey())
            }
        }

        // Now that the filter is setup, we can grab the outputImage from it,
        // which is a CIImage.
        guard let processedImage_ci:CIImage = filter_ci.outputImage else { return }
        
        // Now, convert that CIImage to a CGImage
        guard let processedImage_cg = ciContext.createCGImage(processedImage_ci, from: processedImage_ci.extent) else { return }

        processedImage_ui = UIImage(cgImage: processedImage_cg)
        processedImage = Image(uiImage: processedImage_ui!)
    }
    
    //
    // saveImage
    //
    // Saves an image to the photo library.
    //
    func saveImage(_ callback:((Error?) -> Void)?) {
          
        guard let processedImage_ui = processedImage_ui else { return }
        
        let imageSaver = ImageSaver(handler:callback)
        imageSaver.writeToPhotoAlbum(image: processedImage_ui)
    }
}
