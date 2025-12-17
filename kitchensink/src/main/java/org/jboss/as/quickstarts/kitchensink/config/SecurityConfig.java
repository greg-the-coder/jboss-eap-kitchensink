package org.jboss.as.quickstarts.kitchensink.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Spring Security configuration for the Kitchensink application.
 * 
 * Configures HTTP security, authentication, authorization, and security headers.
 * Uses HTTP Basic authentication for REST API access.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Value("${app.security.user.username:user}")
    private String userUsername;

    @Value("${app.security.user.password:password}")
    private String userPassword;

    @Value("${app.security.admin.username:admin}")
    private String adminUsername;

    @Value("${app.security.admin.password:admin}")
    private String adminPassword;

    /**
     * Configure HTTP security.
     * 
     * @param http the HttpSecurity to configure
     * @return configured SecurityFilterChain
     * @throws Exception if configuration fails
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Enable CORS before other filters
            .cors(cors -> {})
            // Configure authorization rules
            .authorizeHttpRequests(authorize -> authorize
                // Permit access to health and info endpoints
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                // Permit access to REST API for public access (change to authenticated() for production)
                .requestMatchers("/rest/**").permitAll()
                // Require authentication for all other requests
                .anyRequest().authenticated()
            )
            // Enable HTTP Basic authentication
            .httpBasic(basic -> {})
            // Disable CSRF for stateless REST APIs
            .csrf(csrf -> csrf.disable())
            // Stateless session management for REST APIs
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            // Configure security headers
            .headers(headers -> headers
                .frameOptions(frame -> frame.deny())
                .xssProtection(xss -> xss.disable()) // Modern browsers have built-in XSS protection
                .contentTypeOptions(contentType -> {})
                .httpStrictTransportSecurity(hsts -> hsts
                    .includeSubDomains(true)
                    .maxAgeInSeconds(31536000)
                )
            );

        return http.build();
    }

    /**
     * Configure password encoder.
     * Uses BCrypt for secure password hashing.
     * 
     * @return BCryptPasswordEncoder instance
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Configure in-memory user details service for development.
     * 
     * Credentials are externalized via application properties:
     * - app.security.user.username / app.security.user.password
     * - app.security.admin.username / app.security.admin.password
     * 
     * For production, replace with database-backed UserDetailsService
     * or integrate with external identity provider (LDAP, OAuth2, SAML).
     * 
     * @return UserDetailsService with in-memory users
     */
    @Bean
    public UserDetailsService userDetailsService() {
        UserDetails user = User.builder()
            .username(userUsername)
            .password(passwordEncoder().encode(userPassword))
            .roles("USER")
            .build();

        UserDetails admin = User.builder()
            .username(adminUsername)
            .password(passwordEncoder().encode(adminPassword))
            .roles("USER", "ADMIN")
            .build();

        return new InMemoryUserDetailsManager(user, admin);
    }
}
