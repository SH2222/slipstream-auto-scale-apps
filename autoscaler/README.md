## Autoscaler module structure

```
app/
   dashboard.json                # Configuration of the layout of Riemann-dash.
   dashboard.rb                  # Configuration of the Riemann-dash service.
   event-example.json            # An example of Riemann event in JSON.
   project.clj                   # Clojure project file for working with Riemann streams file.
   riemann-ss-streams.clj        # SlipStream scaling logic as Riemann streams.
   scale-constraints-example.edn # Example scale constraints.
deployment/
   deployment.sh                 # Deployment of the autoscaler component.
```
