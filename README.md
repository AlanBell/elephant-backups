Mastodon
================
A Mastodon Never Forgets
--------------------------

This describes a backup solution that is resistant to a number of specific threats. It can be used for anything from a single desktop to a datacenter, but the scenario it was built for is backing up a few dozen LAMP servers. This is quite an untrusting solution compared to most backups over ssh. It is designed so that an attacker could compromise and gain root on the machine being backed up and this wouldn’t help them gain access to the backup server, and they wouldn’t be able to access or destroy backups. Additionally an attacker could compromise and gain root on the backup server and this wouldn’t help them gain access to the backed up machines, and wouldn’t get them access to the backups.

Each machine being backed up must not be aware of, or able to read/destroy the backups of other machines.
Each machine may not destroy backups of itself - even if compromised. There are two situations that concern us here. If an attacker gains root access on the machine, there must not be anything there such as ssh keys or backup credentials that allow the attacker to log on to the backup server and delete old backups. Secondly RAID 1 has a very odd failure mode, it can push a server back in time. If one drive stops being written to and drops out of the RAID this can go unnoticed for some time, the server can then reboot (perhaps because the other drive failed) and can come back up on the drive that hasn’t been written to for a while, going back in time. This must not cause data loss.
The administrator must be notified if a backup doesn’t happen, including if the machine to be backed up fails totally and can’t send you a mail.
The machines being backed up might be behind a firewall and can’t be connected to from the backing up server.
The machines must be safe from a compromised backup server - We can’t have a scenario where someone gaining root on the backup server then has SSH keys to connect back to all the servers.
The backup files must be safe from someone gaining root on the backup server.
The backup files must be safe from other administrators
Blobs get stored on the filesystem, not in a database - possibly in several locations, an administrator may have a quota of storage.
Can support either xdelta for binary incrementals, or using GPG with symetric, or asymetric keys. Asymmetric keys would allow a person to have an offline paper based recovery key - the backed up machine wouldn’t be able to decrypt it’s own backups.
For asymmetric GPG encryption the administrator has the private key, the backed up machine has the public key, so it is a one way thing safe from someone gaining access to the backups.
Throttling, should be a feature - so we can optionally destress the machine being backed up, spread the backups over time or do it as fast as the network allows.

The backup agent on the machines should have very little configuration, just the location of the backup server and optionally any encryption keys. This means that the backup server can’t request unencrypted files if the backup server were to be compromised.
The encryption being used initially is symmetric passphrase encryption - and that will be stored in plain on the client machine. This is OK, if you break into the client machine and can read root’s crontab then you have already won, you have access to all the plain text files that were about to be encrypted. The important thing is that knowing the symmetric encryption key doesn’t help you to destroy or access past backups.

Symlinks
--

We should totally support symbolic and hard links to things, and put them back the way they were if we are doing a restore.
Right now it is just assuming that files are files, it walks a directory tree reading stuff.

Permissions
--

When submitting we should send the uid and gid and permission flags.
We should be aware that when restoring things the uid and gid may be different.

Restoring to the same machine
--

It may be that the machine is not marked as self-restorable, in that case the server won’t serve up old versions of a file to the machine that backed them up.
We should be able to flag any version of any file as “to be restored”
Then after the next backup - so it will do one last backup of the current file - it will restore files queued to be restored. This is going to be for relatively small numbers of files at a time, not a full machine restore.

Downloading one file from the admin interface
--

This is going to be supported, you will be able to download the encrypted file, or give the key and decrypt on the server

Restoring the lot to a new machine
--

You are going to need the symmetric passphrase that the old machine used. Without that your files are toast.
If the whole machine is marked as to be restored, there may be some transforms on the paths to be done.


backup agent to be run from cron

There is no local configuration, just a URL for the backup server that gets passed on the command line and a passkey

Things we care about a lot
--

* If the client machine is compromised it should not help the attacker to attack the backups or backup server
* If the server machine is compromised that should not help the attacker to attack the client or read any backups

Things we care about a little
--

* The system should perform well and fairly on the server side - it should be able to accept multiple machines backing up at once - using all the resources of the server efficiently in parallel and fairly so that a backup of a fast machine can't deny service to a slower client.
* It should be reasonably space efficient, but we prioritise encryption over compression
* It should be network efficient
* It should be fast to restore - this is more important than being fast to backup

Things for which we have not a care in the world
--
* We don't care if this is stressful on the client machine
* We don't care if this is not as multithreaded as it could be on the client machine
