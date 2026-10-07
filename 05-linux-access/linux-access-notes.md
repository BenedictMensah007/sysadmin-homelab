\# Linux access control with Active Directory



Goal: only members of the IT group can log in to Ubuntu, and they get sudo.



The server was already set to allow only permitted logins. I added the IT group to that list and gave it sudo.



```

realm list

sudo realm permit -g gg\_it@lab.local

echo '%gg\_it@lab.local ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/gg\_it

sudo chmod 440 /etc/sudoers.d/gg\_it

sudo visudo -c

```



On a fresh machine, start with `sudo realm deny --all` so nobody is allowed until you permit them.



Result: an IT user logs in and has sudo, an HR user is refused.

