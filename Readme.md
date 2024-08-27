

## Publish

To connect to shinyapps.io, I had to set the token and secret (which was provided by shinyapps.io):

```r
rsconnect::setAccountInfo(name='ratnanil', token='******', secret='******')
``` 

To publish the app, I ran the followig code. However, this bundled several files that were not necessary. Next time, try specifying `appFiles = `.

```r
rsconnect::deployApp()
```