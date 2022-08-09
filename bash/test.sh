# Credits: https://github.com/pawk/how-to-start-with-adp-integration.git

# ------------ CONFIGURATION START --------------
# save your .pem / .key files into bash/certs directory
# that you obtained from Certificate Signing Request process
# make sure names match with those below
export ADP_CERT_PATH=certs/ADP-PublicCertificate.pem
export ADP_KEY_PATH=certs/ADP-PublicCertificate.key

# defined in ADP onboarding document as "Partner Credentials for Data Connector"
export ADP_PARTNER_CLIENT_ID=aaaaaaaa-48d0-dddd-cccc-3b12999934cd
export ADP_PARTNER_CLIENT_SECRET=bbbbbbbb-e912-dddd-aaaa-9799999c219c
# defined in ADP onboarding document as "Sandbox OrganizationOID"
export ADP_SANDBOX_ORGANIZATION_OID=G3DXXXX1XXX1BQRD
# -------------- CONFIGURATION END ---------------

ADP_ACCESS_TOKEN=$(oauth/token)
echo "ADP_ACCESS_TOKEN: $ADP_ACCESS_TOKEN"

CLIENT_CREDENTIALS=$(client-credentials/read $ADP_ACCESS_TOKEN)
echo "CLIENT CREDENTIALS: $CLIENT_CREDENTIALS"

# Cleaning up client credentials to get subscription access token
CLIENT_CREDENTIALS=$(echo $CLIENT_CREDENTIALS | sed 's/{.*clientID":"//; s/","clientSecret":"/ /; s/"}//')
echo "CLIENT CREDENTIALS: $CLIENT_CREDENTIALS"

ADP_SUBSCRIPTION_ACCESS_TOKEN=$(oauth/token $CLIENT_CREDENTIALS)
echo "ADP_SUBSCRIPTION_ACCESS_TOKEN: $ADP_SUBSCRIPTION_ACCESS_TOKEN"

# Uncomment the following to pull workers list from ADP
# workers/get $ADP_SUBSCRIPTION_ACCESS_TOKEN

# Using python : https://requests.readthedocs.io/en/latest/user/advanced/#ssl-cert-verification