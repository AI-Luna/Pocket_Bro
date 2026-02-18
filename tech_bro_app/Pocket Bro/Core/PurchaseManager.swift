//
//  PurchaseManager.swift
//  Pocket Bro
//

import Foundation
import RevenueCat

class PurchaseManager {
    static let shared = PurchaseManager()

    let entitlementIdentifier = "TechBro Pro"

    /// Cached pro status — updated on launch, foreground, and after purchases/restores.
    private(set) var isProActive: Bool = false

    private init() {}

    // MARK: - Entitlement Check

    /// Refresh pro status from RevenueCat. Call on app launch/foreground.
    func refresh(completion: ((Bool) -> Void)? = nil) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, _ in
            guard let self else { return }
            let isPro = customerInfo?.entitlements[self.entitlementIdentifier]?.isActive == true
            self.isProActive = isPro
            DispatchQueue.main.async { completion?(isPro) }
        }
    }

    // MARK: - Offerings

    func fetchOfferings(completion: @escaping (Offerings?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            DispatchQueue.main.async { completion(offerings) }
        }
    }

    // MARK: - Purchase

    func purchase(package: Package, completion: @escaping (Bool, Error?) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] _, customerInfo, error, userCancelled in
            guard let self else { return }
            if userCancelled {
                DispatchQueue.main.async { completion(false, nil) }
                return
            }
            if let error {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            let isPro = customerInfo?.entitlements[self.entitlementIdentifier]?.isActive == true
            self.isProActive = isPro
            DispatchQueue.main.async { completion(isPro, nil) }
        }
    }

    // MARK: - Restore

    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            guard let self else { return }
            if let error {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            let isPro = customerInfo?.entitlements[self.entitlementIdentifier]?.isActive == true
            self.isProActive = isPro
            DispatchQueue.main.async { completion(isPro, nil) }
        }
    }
}
