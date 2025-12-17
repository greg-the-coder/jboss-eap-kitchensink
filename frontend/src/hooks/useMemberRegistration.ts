import { useMutation, useQueryClient } from '@tanstack/react-query';
import { memberApi, getApiErrorMessage, getValidationErrors } from '@/lib/api-client';
import type { MemberRegistrationRequest, Member } from '@/types/member';

export function useMemberRegistration() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (member: MemberRegistrationRequest) => memberApi.registerMember(member),
    onSuccess: (newMember: Member) => {
      // Invalidate and refetch members list
      queryClient.invalidateQueries({ queryKey: ['members'] });
      
      // Optionally add the new member to the cache optimistically
      queryClient.setQueryData<Member[]>(['members'], (old) => {
        if (!old) return [newMember];
        return [...old, newMember];
      });
    },
    meta: {
      getErrorMessage: getApiErrorMessage,
      getValidationErrors: getValidationErrors,
    },
  });
}
