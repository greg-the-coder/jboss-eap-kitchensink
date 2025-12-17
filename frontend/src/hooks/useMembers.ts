import { useQuery } from '@tanstack/react-query';
import { memberApi } from '@/lib/api-client';

export function useMembers() {
  return useQuery({
    queryKey: ['members'],
    queryFn: memberApi.getAllMembers,
    refetchInterval: 30000, // Refetch every 30 seconds
  });
}

export function useMember(id: number) {
  return useQuery({
    queryKey: ['members', id],
    queryFn: () => memberApi.getMemberById(id),
    enabled: !!id,
  });
}
