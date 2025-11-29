# URL Shortener Web Application with DevOps Deployment

## 1. Project Planning

### 1.1 Project Proposal
The **URL Shortener Web Application** is a lightweight web-based system that allows users to convert long URLs into shorter, manageable links.  
It is built using **Flask (Python)** as the backend framework and containerized with **Docker** for portability and deployment.  
This project incorporates **DevOps practices** including containerization, continuous integration (CI), monitoring (**Prometheus**), visualization (**Grafana**), and automated deployment pipelines.

### 1.2 Objectives
- Develop a RESTful web service for shortening URLs.  
- Containerize the application using Docker and manage with Docker Compose.  
- Integrate Prometheus for metrics collection.  
- Build monitoring dashboards in Grafana.  
- Implement CI/CD workflows for automated build and deployment.

### 1.3 Scope
The project covers:
- Web backend (**Flask API**)  
- Database (**SQLite**)  
- Containerization (**Docker**)  
- Monitoring (**Prometheus + Grafana**)  
- Basic frontend UI (for shortening and accessing links)

### 1.4 Project Plan (Timeline & Milestones)

| Week | Task | Deliverables |
|------|------|--------------|
| Week 1 | System setup, Flask API, and Docker containerization | Running containerized web app |
| Week 2 | Metrics integration (Prometheus) | `/metrics` endpoint exposing system stats |
| Week 3 | Grafana setup for visualization | Grafana dashboard linked to Prometheus |
| Week 4 | Alerts, scaling, and documentation | Complete DevOps deployment with docs |

### 1.5 Task Assignment & Roles

| Role | Responsibility |
|------|----------------|
| DevOps Engineer | CI/CD pipeline, Docker setup, Prometheus/Grafana integration |
| Backend Developer | Flask app development, database integration |
| UI/UX Designer | Designing user interface and experience flow |
| QA Engineer | Testing APIs, load testing, monitoring system health |

### 1.6 Risk Assessment & Mitigation

| Risk | Impact | Mitigation |
|------|---------|------------|
| Container build failure | High | Use verified base images and incremental builds |
| Database loss or corruption | Medium | Persistent storage volume and regular backups |
| Service downtime | High | Monitoring alerts and quick rollback via Docker |
| Security vulnerabilities | Medium | Sanitize inputs, restrict network access |

### 1.7 Key Performance Indicators (KPIs)
- API response time ≤ **200 ms**  
- System uptime ≥ **99%**  
- Deployment success rate ≥ **95%**  
- URL creation throughput (req/sec)  
- Average container resource utilization < **70%**

---

## 2. Stakeholder Analysis

| Stakeholder | Role | Needs | Influence |
|--------------|------|--------|------------|
| Project Developer | Designer & maintainer | Efficient build, monitoring setup | High |
| End Users | Consumers of short links | Fast, reliable redirection | High |
| DevOps Engineer | Maintains deployment | Automation, scalability | High |
| QA Tester | Verifies system quality | Easy testability and logging | Medium |
| Lecturer / Evaluator | Reviewer | Complete documentation and functionality | High |

---

## 3. Database Design

The system uses **SQLite** for simplicity and persistence within the Docker container.  
It stores the mapping between short codes and long URLs, along with timestamps.

### 3.1 ER Diagram
**Table: urls**

| Field | Type | Key | Description |
|--------|------|-----|-------------|
| id | INTEGER | PK | Unique identifier |
| short_code | TEXT | UNIQUE | Random 6-character code |
| long_url | TEXT |  | Original long URL |
| created_at | DATETIME |  | Creation timestamp |

**Normalization:** The table follows **1NF, 2NF, and 3NF** as there are no partial or transitive dependencies.

---

## 4. UI/UX Design

### Page 1 – Home (Shorten URL)
- Input field: *Enter long URL*  
- Button: *Shorten*  
- Output: Display shortened link

### Page 2 – Redirect
- When visiting the short link, the system redirects to the long URL or shows *Not Found*.

### 4.1 Mockup Description
- +--------------------------------------------------+
- URL Shortener Web App
- +--------------------------------------------------+
- [ Enter your long URL here.............. ]
-             [ Shorten URL ]
- +--------------------------------------------------+
- Shortened URL: http://localhost:5000/abc123
- +--------------------------------------------------+

### 4.2 UI/UX Guidelines
- **Color Scheme:** Blue (Primary), White (Background), Gray (Neutral text)  
- **Typography:** Sans-serif (Open Sans, Roboto)  
- **Accessibility:** Large text, clear contrast, keyboard navigable  
- **Responsiveness:** Layout adapts to mobile and desktop viewports  
- **Usability Principle:** “One-click” shortening, clear feedback messages  


