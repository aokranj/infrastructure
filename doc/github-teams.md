# GitHub teams - AO Kranj

At this point, we're not distinguishing between AO and PD, as the same people
are managing both websites.

Team structure, with a brief description of each team's purpose:
```
@everyone               # Anyone not in other teams
  @github-org-admins    # People with "owner" role to https://github.com/aokranj organisation
  @mgmt                 # AO Kranj leaders ("nacelnik")

  @eng                  # Engineering team
    @devs
      @devs-ro          # Placeholder team for engineers before they gain write access to app Git repos.
      @devs-rw          # Mostly all engineers that do not have access to prod (but do have write access to app repos)

    @ops
      @ops-prod         # Engineers with prod access (access to create prod tags, k8s access,
                        # filesyste access to prod environment, read access to backups.
                        # Must have `maintain` role assigned in repos to enable creation of protected tags (for deployment to prod).
      @ops-root         # Infrastructure engineers (access to everything)
```
