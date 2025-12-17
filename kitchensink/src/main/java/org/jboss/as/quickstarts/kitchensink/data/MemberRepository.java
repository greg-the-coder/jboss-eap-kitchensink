/*
 * JBoss, Home of Professional Open Source
 * Copyright 2014, Red Hat, Inc. and/or its affiliates, and individual
 * contributors by the @authors tag. See the copyright.txt in the
 * distribution for a full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jboss.as.quickstarts.kitchensink.data;

import java.util.List;
import java.util.Optional;

import org.jboss.as.quickstarts.kitchensink.model.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

/**
 * Spring Data JPA repository for Member entities.
 * 
 * This interface replaces the CDI-based repository with Spring Data JPA,
 * eliminating the need for manual EntityManager and Criteria API code.
 * Spring Data JPA will automatically implement these methods based on
 * naming conventions and annotations.
 */
@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    /**
     * Find a member by email address.
     * Spring Data JPA derives the query from the method name.
     * 
     * @param email the email address to search for
     * @return Optional containing the member if found, empty otherwise
     */
    Optional<Member> findByEmail(String email);

    /**
     * Find all members ordered by name in ascending order.
     * Using @Query annotation for clarity, but could also use:
     * List<Member> findAllByOrderByNameAsc()
     * 
     * @return list of all members sorted by name
     */
    @Query("SELECT m FROM Member m ORDER BY m.name ASC")
    List<Member> findAllOrderedByName();
}
