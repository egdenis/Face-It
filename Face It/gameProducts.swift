import Foundation

public struct gameProducts {
    
    // TODO:  Change this to the BundleID chosen when registering this app's App ID in the Apple Member Center.
    private static let Prefix = "com.etiennedenis.faceit."
    
    public static let cancelads = Prefix + "cancelads" //can do dynamic
    
    private static let productIdentifiers: Set<ProductIdentifier> = [gameProducts.cancelads]
    
    
    // TODO: This is the code that would be used if you added iPhoneRage, NightlyRage, and UpdogRage to the list of purchasable
    //       products in iTunesConnect.
    /*
     public static let GirlfriendOfDrummerRage = Prefix + "GirlfriendOfDrummerRage"
     public static let iPhoneRage              = Prefix + "iPhoneRage"
     public static let NightlyRage             = Prefix + "NightlyRage"
     public static let UpdogRage               = Prefix + "UpdogRage"
     
     private static let productIdentifiers: Set<ProductIdentifier> = [RageProducts.GirlfriendOfDrummerRage,
     RageProducts.iPhoneRage,
     RageProducts.NightlyRage,
     RageProducts.UpdogRage]
     */
    public static let store = IAPHelper(productIds: gameProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.componentsSeparatedByString(".").last
}