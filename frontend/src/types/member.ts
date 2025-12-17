/**
 * Member entity type matching the Spring Boot backend Member entity
 */
export interface Member {
  id: number;
  name: string;
  email: string;
  phoneNumber: string;
}

/**
 * Member registration request (without ID)
 */
export interface MemberRegistrationRequest {
  name: string;
  email: string;
  phoneNumber: string;
}

/**
 * API error response structure
 */
export interface ApiErrorResponse {
  timestamp: string;
  status: number;
  error: string;
  message: string;
  path: string;
  validationErrors?: Record<string, string>;
}
