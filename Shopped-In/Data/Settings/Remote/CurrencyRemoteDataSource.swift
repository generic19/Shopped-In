//
//  CurrencyRemoteDataSource.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 21/06/2025.
//


import Foundation

protocol CurrencyRemoteDataSource {
    func getUSDPrice(completion: @escaping (Result<Double, Error>) -> Void)
}