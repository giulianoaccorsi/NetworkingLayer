import XCTest
@testable import NetworkingLayer

final class RetryPolicyTests: XCTestCase {
    
    // MARK: - DefaultRetryPolicy Tests
    
    func testDefaultRetryPolicyConfiguration() {
        let policy = DefaultRetryPolicy()
        
        XCTAssertEqual(policy.maxRetries, 3)
    }
    
    func testDefaultRetryPolicyCustomConfiguration() {
        let policy = DefaultRetryPolicy(
            maxRetries: 5,
            baseDelay: 2.0,
            maxDelay: 60.0,
            backoffMultiplier: 3.0
        )
        
        XCTAssertEqual(policy.maxRetries, 5)
    }
    
    func testDefaultRetryPolicyShouldRetryForNetworkErrors() {
        let policy = DefaultRetryPolicy()
        let networkError = ServiceError.networkError(URLError(.notConnectedToInternet))
        
        XCTAssertTrue(policy.shouldRetry(for: networkError, attempt: 0))
        XCTAssertTrue(policy.shouldRetry(for: networkError, attempt: 1))
        XCTAssertTrue(policy.shouldRetry(for: networkError, attempt: 2))
        XCTAssertFalse(policy.shouldRetry(for: networkError, attempt: 3))
    }
    
    func testDefaultRetryPolicyShouldNotRetryForClientErrors() {
        let policy = DefaultRetryPolicy()
        let clientError = ServiceError.invalidStatusCode(400)
        
        XCTAssertFalse(policy.shouldRetry(for: clientError, attempt: 0))
        XCTAssertFalse(policy.shouldRetry(for: clientError, attempt: 1))
    }
    
    func testDefaultRetryPolicyExponentialBackoff() {
        let policy = DefaultRetryPolicy(baseDelay: 1.0, backoffMultiplier: 2.0)
        
        XCTAssertEqual(policy.delay(for: 0), 1.0)
        XCTAssertEqual(policy.delay(for: 1), 2.0)
        XCTAssertEqual(policy.delay(for: 2), 4.0)
    }
    
    // MARK: - NoRetryPolicy Tests
    
    func testNoRetryPolicy() {
        let policy = NoRetryPolicy()
        
        XCTAssertEqual(policy.maxRetries, 0)
        XCTAssertFalse(policy.shouldRetry(for: ServiceError.networkError(URLError(.notConnectedToInternet)), attempt: 0))
        XCTAssertEqual(policy.delay(for: 0), 0)
    }
    
    // MARK: - LinearRetryPolicy Tests
    
    func testLinearRetryPolicy() {
        let policy = LinearRetryPolicy(maxRetries: 3, delay: 2.0)
        
        XCTAssertEqual(policy.maxRetries, 3)
        XCTAssertEqual(policy.delay(for: 0), 2.0)
        XCTAssertEqual(policy.delay(for: 1), 2.0)
        XCTAssertEqual(policy.delay(for: 2), 2.0)
    }
    
    // MARK: - NetworkServiceWithRetry Tests
    
    func testRetryServiceConvenienceInitializers() {
        let exponentialService = NetworkServiceWithRetry.withExponentialBackoff(maxRetries: 5)
        let linearService = NetworkServiceWithRetry.withLinearRetry(maxRetries: 3, delay: 2.0)
        let noRetryService = NetworkServiceWithRetry.withoutRetry()
    
        XCTAssertNotNil(exponentialService)
        XCTAssertNotNil(linearService)
        XCTAssertNotNil(noRetryService)
    }
} 
