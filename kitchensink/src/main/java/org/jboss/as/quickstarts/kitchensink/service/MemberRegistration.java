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
package org.jboss.as.quickstarts.kitchensink.service;

import org.jboss.as.quickstarts.kitchensink.data.MemberRepository;
import org.jboss.as.quickstarts.kitchensink.model.Member;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Spring Service component for member registration.
 * 
 * This class replaces the EJB @Stateless bean with Spring's @Service,
 * using constructor-based dependency injection and Spring's transaction management.
 */
@Service
public class MemberRegistration {

    private static final Logger log = LoggerFactory.getLogger(MemberRegistration.class);

    private final MemberRepository memberRepository;
    private final ApplicationEventPublisher eventPublisher;

    /**
     * Constructor-based dependency injection (preferred over field injection).
     * 
     * @param memberRepository the repository for member data access
     * @param eventPublisher Spring's event publisher for publishing member registration events
     */
    public MemberRegistration(MemberRepository memberRepository, 
                             ApplicationEventPublisher eventPublisher) {
        this.memberRepository = memberRepository;
        this.eventPublisher = eventPublisher;
    }

    /**
     * Register a new member.
     * 
     * @Transactional ensures this method runs in a transaction (replaces EJB's automatic transaction management)
     * 
     * @param member the member to register
     * @throws Exception if registration fails
     */
    @Transactional
    public void register(Member member) throws Exception {
        log.info("Registering {}", member.getName());
        memberRepository.save(member);
        eventPublisher.publishEvent(new MemberRegistrationEvent(member));
    }

    /**
     * Inner class for type-safe event handling.
     * Spring's event model uses ApplicationEvent or POJO events.
     */
    public static class MemberRegistrationEvent {
        private final Member member;

        public MemberRegistrationEvent(Member member) {
            this.member = member;
        }

        public Member getMember() {
            return member;
        }
    }
}
