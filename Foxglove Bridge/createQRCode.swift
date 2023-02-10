import class UIKit.UIImage
import CoreImage
import CoreImage.CIFilterBuiltins

func createQRCode(_ string: String) -> UIImage? {
  guard let data = string.data(using: .ascii) else {
    return nil
  }

  let qrGenerator = CIFilter.qrCodeGenerator()
  qrGenerator.message = data

  let invert = CIFilter.colorInvert()
  invert.inputImage = qrGenerator.outputImage

  let mask = CIFilter.maskToAlpha()
  mask.inputImage = invert.outputImage

  guard let ciImage = mask.outputImage else {
    return nil
  }
  guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
    return nil
  }

  return UIImage(cgImage: cgImage)
}
