**Deployment
```
edge:drivers:package <ordner>	Baut den Treiber und lädt ihn in dein Konto hoch. Er ist dann noch auf keinem Hub.
edge:channels:create	Legt einen Channel an. Das machst du einmalig.
edge:channels:assign [driver-id] [version]	Weist einem Channel, den du besitzt, einen bestimmten Treiber in einer bestimmten Version zu.
edge:channels:enroll [hub-id]	Meldet den Hub beim Channel an (einmalig pro Hub und Channel).
edge:drivers:install	Installiert einen Treiber aus einem deiner Channels auf den Hub. Mit --hub bzw. -H gibst du die Hub-ID an, sonst wählst du aus einer Liste. 
driver channels
 +2
```
