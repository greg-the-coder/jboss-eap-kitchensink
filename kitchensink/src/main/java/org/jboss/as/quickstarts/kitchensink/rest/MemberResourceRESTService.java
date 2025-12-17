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
package org.jboss.as.quickstarts.kitchensink.rest;

import java.util.List;

import org.jboss.as.quickstarts.kitchensink.data.MemberRepository;
import org.jboss.as.quickstarts.kitchensink.model.Member;
import org.jboss.as.quickstarts.kitchensink.service.MemberRegistration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import jakarta.validation.Valid;

/**
 * Spring MVC REST Controller
 * <p/>
 * This class produces a RESTful service to read/write the contents of the members table.
 * Converted from JAX-RS to Spring MVC REST Controller.
 */
@RestController
@RequestMapping("/rest/members")
public class MemberResourceRESTService {

    private static final Logger log = LoggerFactory.getLogger(MemberResourceRESTService.class);

    private final MemberRepository repository;
    private final MemberRegistration registration;

    /**
     * Constructor-based dependency injection.
     * 
     * @param repository the member repository
     * @param registration the member registration service
     */
    public MemberResourceRESTService(MemberRepository repository, MemberRegistration registration) {
        this.repository = repository;
        this.registration = registration;
    }

    /**
     * List all members ordered by name.
     * Spring MVC automatically converts the List to JSON.
     * 
     * @return list of all members
     */
    @GetMapping(produces = "application/json")
    public List<Member> listAllMembers() {
        return repository.findAllOrderedByName();
    }

    /**
     * Lookup a member by ID.
     * 
     * @param id the member ID
     * @return the member
     * @throws ResponseStatusException if member not found
     */
    @GetMapping(value = "/{id:[0-9]+}", produces = "application/json")
    public ResponseEntity<Member> lookupMemberById(@PathVariable("id") Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Member not found"));
    }

    /**
     * Creates a new member from the values provided.
     * 
     * @Valid triggers Bean Validation on the member object.
     * Spring's exception handling (via @ControllerAdvice) handles validation errors.
     * 
     * @param member the member to create
     * @return ResponseEntity with created member or error status
     */
    @PostMapping(consumes = "application/json", produces = "application/json")
    public ResponseEntity<Member> createMember(@Valid @RequestBody Member member) {
        try {
            // Check for duplicate email
            if (emailAlreadyExists(member.getEmail())) {
                throw new DataIntegrityViolationException("Email already exists");
            }

            registration.register(member);
            log.info("Member registered successfully: {}", member.getEmail());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(member);
        } catch (DataIntegrityViolationException e) {
            log.warn("Duplicate email attempt: {}", member.getEmail());
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists", e);
        } catch (Exception e) {
            log.error("Error registering member: {}", e.getMessage(), e);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Error registering member", e);
        }
    }

    /**
     * Checks if a member with the same email address is already registered.
     * 
     * @param email The email to check
     * @return True if the email already exists, and false otherwise
     */
    public boolean emailAlreadyExists(String email) {
        return repository.findByEmail(email).isPresent();
    }
}
