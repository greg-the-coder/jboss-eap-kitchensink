import { z } from 'zod';

/**
 * Member registration validation schema
 * Matches the Bean Validation constraints in the Spring Boot backend Member entity
 */
export const memberRegistrationSchema = z.object({
  name: z
    .string()
    .min(1, 'Name is required')
    .max(25, 'Name must be 25 characters or less')
    .regex(/^[^0-9]+$/, 'Name must not contain numbers'),
  
  email: z
    .string()
    .min(1, 'Email is required')
    .email('Must be a valid email address'),
  
  phoneNumber: z
    .string()
    .min(1, 'Phone number is required')
    .regex(/^\d{10,12}$/, 'Phone number must be 10-12 digits'),
});

export type MemberRegistrationFormData = z.infer<typeof memberRegistrationSchema>;
