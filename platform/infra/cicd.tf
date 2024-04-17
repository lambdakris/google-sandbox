# Establish a random id for appending to the github identity pool id in order to avoid conflicts with deprovisioned pools
resource "random_id" "github" {
    byte_length = 4
}

# Establish Github Identity Pool
resource "google_iam_workload_identity_pool" "github" {
    workload_identity_pool_id = "github-pool-${random_id.github.hex}"
}

# Establish Github Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github" {
    workload_identity_pool_id = google_iam_workload_identity_pool.github.workload_identity_pool_id
    workload_identity_pool_provider_id = "github-pool-provider"
    attribute_mapping = {
        "google.subject" = "assertion.sub"
        "attribute.repository" = "assertion.repository"
        "attribute.repository_owner" = "assertion.repository_owner"
        "attribute.ref" = "assertion.ref"
    }
    oidc {
        issuer_uri = "https://token.actions.githubusercontent.com"
    }
}

# Establish Github Service Account
resource "google_service_account" "github" {
    account_id = "github-account"
}

# Establish Github Service Account Workload Federation
# let the member - github repo - impersonate the service_account
resource "google_service_account_iam_member" "github_workload" {
    service_account_id = google_service_account.github.name
    role = "roles/iam.workloadIdentityUser"
    member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/lambdakris/google-sandbox"
}

resource "google_project_iam_custom_role" "github" {
    role_id = "github"
    title = "Github Role"
    stage = "ALPHA"
    permissions = [
        "storage.objects.list",
        "storage.objects.get",
        "storage.objects.create",
        "storage.objects.delete",
        "storage.objects.update",
        "run.services.get",
        "run.services.create",
        "run.services.delete",
        "run.services.update",
        "run.services.getIamPolicy",
        "run.services.setIamPolicy",
        "run.jobs.get",
        "run.jobs.create",
        "run.jobs.delete",
        "run.jobs.update",
        "run.jobs.getIamPolicy",
        "run.jobs.setIamPolicy",
        "run.operations.get",
        "artifactregistry.repositories.create",
        "artifactregistry.repositories.createTagBinding",
        "artifactregistry.repositories.delete",
        "artifactregistry.repositories.deleteArtifacts",
        "artifactregistry.repositories.deleteTagBinding",
        "artifactregistry.repositories.downloadArtifacts",
        "artifactregistry.repositories.get",
        "artifactregistry.repositories.getIamPolicy",
        "artifactregistry.repositories.list",
        "artifactregistry.repositories.listEffectiveTags",
        "artifactregistry.repositories.listTagBindings",
        "artifactregistry.repositories.readViaVirtualRepository",
        "artifactregistry.repositories.setIamPolicy",
        "artifactregistry.repositories.update",
        "artifactregistry.repositories.uploadArtifacts",
        "artifactregistry.tags.create",
        "artifactregistry.tags.delete",
        "artifactregistry.tags.get",
        "artifactregistry.tags.list",
        "artifactregistry.tags.update",
        "artifactregistry.versions.delete",
        "artifactregistry.versions.get",
        "artifactregistry.versions.list",
        "iam.serviceAccounts.actAs",
        "iam.serviceAccounts.get",
        "iam.serviceAccounts.list",
        "iam.serviceAccounts.create",
        "resourcemanager.projects.getIamPolicy",
        "resourcemanager.projects.setIamPolicy"
    ]
}

resource "google_project_iam_member" "github" {
    project = var.project
    role = google_project_iam_custom_role.github.id
    member = "serviceAccount:${google_service_account.github.email}"
}