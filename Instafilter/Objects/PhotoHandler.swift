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
    
    // originalImage is the image downloaded with the picker from the photo
    // library. It is only ever udpated if the image is saved. prevFilteredImage
    // is the image with any previous filters applied to it. Thus, if a user
    // uses sepia, and is currently using crystallize, prevFilteredImage will
    // have the sepia effect on it. The ph will apply the current filter to this
    // image based on slider value. currentFilterImage contains that current filter.
    // It is used for display and to be saved to disk.
    private var originalImage_ui:UIImage? = nil
    private var prevFilteredImage_ui:UIImage? = nil
    private var currentFilteredImage_ui:UIImage? = nil
    
    // client SwiftUI image to display
    @Published var displayImage:Image? = nil
    
    // The set filter type to be used by CoreImage.
    @Published private(set) var filterType:FilterType = .none
    
    // Array of filter inputs supported by a filter and loaded from
    // FilterHandler
    @Published var filterInputs:[FilterInput] = []
    
    // The main CoreImage filter. We are using CIFilter instead
    // of a specific filter type so we can hold different filters
    // in the same variable.
    private var filter_ci:CIFilter?

    // Expensive to allocate. Only allocate once.
    let ciContext = CIContext()
    
    // I would expect, eventually, for this to be read out of persistent memory.
    // For now I will init as if its the first run and put the first 5 filters
    // in the filter enum in the list.
    let top5Filters:[String] = FilterType.listOfFilters(limit:5)

    //init to a blank filter
    init() {
        setFilter(.none)
    }
    
    // setFilter
    //
    // A new filter has been selected by the client. the filterInput dictionary
    // should be cleaned out so the correct filter inputs can be setup for the
    // new filter. The new filter is allocated (via the enum function) and the
    // type of filter is set.
    //
    // Leaving this function the filter has been setup but no filter inputs
    // have been configured (such as intensity, radius, or scale).
    func setFilter(_ newFilterType:FilterType) {
                
        filterType = newFilterType
        filter_ci = newFilterType.initFilter()
        filterInputs.removeAll()
        
        // No matter what persist any changes made to the current image
        persistChanges()
        
        // Nothing else to do if there is no filter type
        guard newFilterType != .none else {
            print("setFilter: Filter type of .none is set.")
            return
        }
        
        guard let inputType = filterType.inputType() else {
            print("setFilter: filterType.inputType returned nil")
            return
        }
        
        print("setFilter: filterType of \(filterType.rawValue) is set.")
        
        // Configure inputs supported by this filter.
        for inputTuple in inputType {
                        
            print("configureInputs: Configuring input \(inputTuple.input.rawValue) with range \(inputTuple.range)")
            
            let filterInput = FilterInput(name: inputTuple.input.rawValue,
                                          range: inputTuple.range,
                                          type: inputTuple.input,
                                          value: (inputTuple.range.upperBound - inputTuple.range.lowerBound)/2 + inputTuple.range.lowerBound)
                
            filterInputs.append(filterInput)
            setFilterInputLevel(filterInput.type, value:filterInput.value)
        }
    }
    
    // setFilterInputLevel
    //
    // Allows a caller to set the leven of the specified input type
    func setFilterInputLevel(_ type:FilterInputType, value:Double) {
  
        filterInputs = filterInputs.map { input -> FilterInput in
            let newInput = input
            if input.type == type {
                newInput.value = value
                print("setFilterInputLevel: \(type.rawValue) = \(value)")
            } else {
                print("setFilterInputLevel: Input type not found.")
            }
            
            return newInput
        }

        // A level has been changed, let's reprocess the image.
        processImage()
    }
    
    // loadNewImage
    //
    // Called when originalImage_ui changes (via the ImagePicker view that allows
    // the user to select something from the photo library. When pickerImage_ui
    // changes (via a binding of it to ImagePIcker), then the loadImage func here
    // is called.
    func loadNewImage(_ newImage_ui:UIImage?) {
        
        guard let newImage_ui = newImage_ui else {
            print("loadNewImage: Passed a nil image.")
            return
        }

        self.originalImage_ui = newImage_ui
        self.prevFilteredImage_ui = newImage_ui
        self.currentFilteredImage_ui = newImage_ui
        
        displayImage = Image(uiImage: newImage_ui)
    }
    

    // processImage
    //
    // Applies filter to the prevFilteredImage to produce the currentFilteredImage.
    // If filtering is successful updates the displayImage.
    func processImage() {
        
        // Unwrap pickerImage_ui
        guard let prevFilteredImage_ui = self.prevFilteredImage_ui else { return }
        
        // Convert the selected UIImage to a CIImage - which is the only thing
        // CoreImage can process.
        let prevFilteredImage_ci = CIImage(image: prevFilteredImage_ui)
        
        // If filter_ci is nil, there is no filter, so we should store the input
        // image as is so it can be rendered in the above view.
        guard let filter_ci = filter_ci else {
            print("processImage: filter_ci is nil, setting processed image to picker image.")
           // processedImage_ui = workingImage_ui  //need to fix this.
            displayImage = Image(uiImage: prevFilteredImage_ui)
            return
        }
        
        // I guess this stores the image in the filter identified by an inputkey
        filter_ci.setValue(prevFilteredImage_ci, forKey: kCIInputImageKey)
        
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
        // TODO: should I set the filter_ci to nil if this fails?
        //
        // Now that the filter is setup, we can grab the outputImage from it,
        // which is a CIImage.
        guard let currentFilteredImage_ci:CIImage = filter_ci.outputImage else {
            print("processImage: CI output image creation failed.")
            //processedImage_ui = workingImage_ui //need to fix
            displayImage = Image(uiImage: prevFilteredImage_ui)
            
            return
        }
            
        // Now, convert that CIImage to a CGImage
        guard let currentFilteredImage_cg:CGImage = ciContext.createCGImage(currentFilteredImage_ci, from: currentFilteredImage_ci.extent) else {
            print("processImage: CG image creation failed.")
            //processedImage_ui = workingImage_ui
            displayImage = Image(uiImage: prevFilteredImage_ui)
            return
        }

        self.currentFilteredImage_ui = UIImage(cgImage: currentFilteredImage_cg)
        displayImage = Image(uiImage: self.currentFilteredImage_ui!)
    }
    
    // resetImage
    //
    // Move back to original image.
    func resetImage() {
        
        guard let originalImage_ui = originalImage_ui else {
            print("resetImage: originalImage_ui is nil. Setting workingImage to nil as well.")

            prevFilteredImage_ui = nil
            currentFilteredImage_ui = nil
            displayImage = nil
            
            return
        }

        prevFilteredImage_ui = originalImage_ui
        currentFilteredImage_ui = originalImage_ui

        displayImage = Image(uiImage: originalImage_ui)
    }
    
    // persistChanges
    //
    // Pushes currentFilterChanges into prevFilterChanges when the user
    // selects another filter.
    func persistChanges() {
        
        prevFilteredImage_ui = currentFilteredImage_ui//todo - anything more?
    }
    
    // saveImage
    //
    // Saves an image to the photo library.
    //
    // TODO: need to make sure change have happened before allowing save.
    func saveImage(_ callback:((Error?) -> Void)?) {
          
        guard let saveImage_ui = currentFilteredImage_ui else { return }
        
        // persist changes into all images so it will be just like loading
        // a new image from the photo library.
        prevFilteredImage_ui = saveImage_ui
        originalImage_ui = saveImage_ui
        
        let imageSaver = ImageSaver(handler:callback)
        imageSaver.writeToPhotoAlbum(image: saveImage_ui)
    }
}
