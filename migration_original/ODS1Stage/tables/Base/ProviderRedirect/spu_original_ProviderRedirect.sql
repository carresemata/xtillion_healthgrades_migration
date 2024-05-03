-- a bunch of code creating the temporary version of Mid.Provider ...
-- to then update Base.ProviderRedirect.ProviderURLNew with the new value from Mid.Provider.ProviderURL

update		a set a.ProviderURLNew = b.ProviderURL
FROM		Base.ProviderRedirect a
INNER JOIN	#Provider b -- Temp version of Mid.Provider
            on b.ProviderCode = a.ProviderCodeNew
WHERE		a.ProviderURLNew is not null
            AND b.ProviderURL != a.ProviderURLNew
            AND a.DeactivationReason not in ('Deactivated','HomePageRedirect')