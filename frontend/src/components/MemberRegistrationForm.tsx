'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { memberRegistrationSchema, type MemberRegistrationFormData } from '@/lib/validation-schemas';
import { useMemberRegistration } from '@/hooks/useMemberRegistration';
import { FormField } from './ui/FormField';
import { Toast } from './ui/Toast';
import { getApiErrorMessage } from '@/lib/api-client';

export function MemberRegistrationForm() {
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' | 'info' } | null>(null);
  
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<MemberRegistrationFormData>({
    resolver: zodResolver(memberRegistrationSchema),
  });

  const mutation = useMemberRegistration();

  const onSubmit = async (data: MemberRegistrationFormData) => {
    try {
      await mutation.mutateAsync(data);
      setToast({
        message: `${data.name} registered successfully!`,
        type: 'success',
      });
      reset(); // Reset form after successful registration
    } catch (error) {
      const errorMessage = getApiErrorMessage(error);
      setToast({
        message: errorMessage,
        type: 'error',
      });
    }
  };

  return (
    <>
      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
      
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-800 mb-6">Register Member</h2>
        
        <form onSubmit={handleSubmit(onSubmit)} noValidate>
          <FormField
            label="Name"
            type="text"
            placeholder="Your name"
            helperText="Must be 1-25 characters, no numbers"
            error={errors.name}
            required
            {...register('name')}
          />

          <FormField
            label="Email"
            type="email"
            placeholder="your.email@example.com"
            helperText="Valid email address"
            error={errors.email}
            required
            {...register('email')}
          />

          <FormField
            label="Phone Number"
            type="tel"
            placeholder="1234567890"
            helperText="10-12 digits only"
            error={errors.phoneNumber}
            required
            {...register('phoneNumber')}
          />

          <button
            type="submit"
            disabled={isSubmitting || mutation.isPending}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center gap-2"
          >
            {(isSubmitting || mutation.isPending) && (
              <svg
                className="animate-spin h-5 w-5 text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
            )}
            {(isSubmitting || mutation.isPending) ? 'Registering...' : 'Register'}
          </button>
        </form>
      </div>
    </>
  );
}
