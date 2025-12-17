import axios, { AxiosError } from 'axios';
import type { Member, MemberRegistrationRequest, ApiErrorResponse } from '@/types/member';

/**
 * API client configuration
 */
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

/**
 * API client for interacting with the Spring Boot backend
 */
export const memberApi = {
  /**
   * Get all members
   */
  getAllMembers: async (): Promise<Member[]> => {
    const response = await apiClient.get<Member[]>('/rest/members');
    return response.data;
  },

  /**
   * Get a member by ID
   */
  getMemberById: async (id: number): Promise<Member> => {
    const response = await apiClient.get<Member>(`/rest/members/${id}`);
    return response.data;
  },

  /**
   * Register a new member
   */
  registerMember: async (member: MemberRegistrationRequest): Promise<Member> => {
    const response = await apiClient.post<Member>('/rest/members', member);
    return response.data;
  },
};

/**
 * Extract error message from API error response
 */
export const getApiErrorMessage = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    
    if (axiosError.response?.data) {
      const errorData = axiosError.response.data;
      
      // If there are validation errors, return the first one
      if (errorData.validationErrors) {
        const firstError = Object.values(errorData.validationErrors)[0];
        return firstError || errorData.message || 'Validation failed';
      }
      
      return errorData.message || 'An error occurred';
    }
    
    if (axiosError.message) {
      return axiosError.message;
    }
  }
  
  if (error instanceof Error) {
    return error.message;
  }
  
  return 'An unexpected error occurred';
};

/**
 * Extract validation errors from API error response
 */
export const getValidationErrors = (error: unknown): Record<string, string> | null => {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    return axiosError.response?.data?.validationErrors || null;
  }
  return null;
};

export default apiClient;
