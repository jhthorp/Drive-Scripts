# Drive Scripts

The scripts within this project are for useful operations across all supported 
operating systems for any drive procedures such as Burn-In/Erase processes.

## Table of Contents

* [Warnings](#warnings)
* [Getting Started](#getting-started)
* [Prerequisites](#prerequisites)
* [Setup](#setup)
* [Scripts](#scripts)
	* [Burn-In](#burn-in)
		* [burnin_drives.sh](#burnin_drivessh)
		* [burnin_drive.sh](#burnin_drivesh)
	* [Erase](#erase)
		* [erase_drives.sh](#erase_drivessh)
		* [erase_drive.sh](#erase_drivesh)
* [Deployment](#deployment)
* [Dependencies](#dependencies)
* [Notes](#notes)
* [Test Environments](#test-environments)
	* [Operating System Compatibility](#operating-system-compatibility)
	* [Hardware Compatibility](#hardware-compatibility)
* [Contributing](#contributing)
* [Support](#support)
* [Versioning](#versioning)
* [Authors](#authors)
* [Copyright](#copyright)
* [License](#license)
* [Acknowledgments](#acknowledgments)

## Warnings

| :warning: |                      :warning:                       | :warning: |
|   :---:   |                        :---:                         |   :---:   |
| :warning: |**Executing Burn-In/Erase scripts will destroy data!**| :warning: |
| :warning: |                      :warning:                       | :warning: |

## Getting Started

These instructions will get you a copy of the project up and running on your 
local machine for development and testing purposes. See 
[deployment](#deployment) for notes on how to deploy the project on a live 
system.

### Prerequisites

* [Utility-Scripts](https://github.com/jhthorp/Utility-Scripts) exist at the 
same directory path

### Setup

In order to use the scripts within this package, you will need to clone, or 
download, the [Utility-Scripts](https://github.com/jhthorp/Utility-Scripts) 
repository into the same top-level directory path.

```
/path/to/Utility-Scripts
/path/to/Drive-Scripts
```

## Scripts

### Burn-In

#### burnin_drives.sh

A script to begin a drive Burn-In for a collection of drives.

The following steps will be performed:
1. Start a new TMUX session named “drive_burnin[_{session_suffix}]” (The brackets ([]) indicate the format used if a suffix is provided)
2. Pull drive list from passed in values or grab all available SMART drives
3. Prompt for the user to confirm, if not ask about each drive
4. Setup a TMUX grid layout for all drives being burned in
5. Attach to the new TMUX session
6. Start the Burn-In process
7. End the TMUX session, if chosen, on detach

_Usage_

```
[bash] ./burnin_drives.sh [drives_override] [zero_drives] [session_suffix] 
[end_on_detach]
```

_Options_

| Option Flag |                          Description                           |
|    :---:    |                             :---:                              |
|     N/A     |                              N/A                               |

_Parameters_

|         Parameter         |                   Description                    |
|           :---:           |                      :---:                       |
|      Drives Override      |          Array of drive IDs to burn-in           |
|        Zero Drives        |   Zero the drives after testing has completed    |
|      Session Suffix       |        Suffix to add to the session name         |
|       End On Detach       |  End process when the TMUX session is detached   |

_Examples_

* **./burnin_drives.sh** "/dev/da0 /dev/da1 /dev/da2"
* **./burnin_drives.sh** "/dev/da0 /dev/da1 /dev/da2" true
* **./burnin_drives.sh** "/dev/da0 /dev/da1 /dev/da2" false "session2"
* **./burnin_drives.sh** "/dev/da0 /dev/da1 /dev/da2" false "session2" true

_Drives Tested_

|        Status        |                       Component                       |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |                   WD Red Plus (8TB)                   |
|  :white_check_mark:  |                   WD Red Plus (6TB)                   |
|  :white_check_mark:  |                     WD Red (6TB)                      |
|  :white_check_mark:  |                   WD Red Plus (3TB)                   |
|  :white_check_mark:  |                  Kingston 240GB A400                  |

#### burnin_drive.sh

A script to begin a drive Burn-In for a single drive.

The following steps will be performed:
1.  Pull drive info and display it
2.  Run a SMART conveyance test
3.  Run a SMART short test
4.  Run a SMART long test
5.  Read SMART results and display them
6.  Run a basic imaging write test
7.  Read SMART results and display them
8.  Run a basic imaging read test
9.  Read SMART results and display them
10. HDD/SSD Specific Steps
    1. HDD
        1. Run a basic imaging read-write test
        2. Read SMART results and display them
        3. Run a destructive BadBlocks test
        4. Read SMART results and display them
    2. SSD
        1. Nothing at this time
11. Run a SMART conveyance test
12. Run a SMART short test
13. Run a SMART long test
14. Read SMART results and display them
15. If desired, zero-out the drive, otherwise write random data across it
16. Pull drive info and display it

_Usage_

```
[bash] ./burnin_drive.sh <drive> [zero_drive]
```

_Options_

| Option Flag |                          Description                           |
|    :---:    |                             :---:                              |
|     N/A     |                              N/A                               |

_Parameters_

|         Parameter         |                   Description                    |
|           :---:           |                      :---:                       |
|           Drive           |                  Drive to test                   |
|        Zero Drive         |    Zero the drive after testing has completed    |

_Examples_

* **./burnin_drive.sh** "/dev/da1"
* **./burnin_drive.sh** "/dev/da1" true

_Drives Tested_

|        Status        |                       Component                       |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |                   WD Red Plus (8TB)                   |
|  :white_check_mark:  |                   WD Red Plus (6TB)                   |
|  :white_check_mark:  |                     WD Red (6TB)                      |
|  :white_check_mark:  |                   WD Red Plus (3TB)                   |
|  :white_check_mark:  |                  Kingston 240GB A400                  |

### Erase

#### erase_drives.sh

A script to begin a drive erase for a collection of drives.

The following steps will be performed:
1. Start a new TMUX session named “drive_erase[_{session_suffix}]” (The brackets ([]) indicate the format used if a suffix is provided)
2. Pull drive list from passed in values or grab all available SMART drives
3. Prompt for the user to confirm, if not ask about each drive
4. Setup a TMUX grid layout for all drives being erased
5. Attach to the new TMUX session
6. Start the Erase process
7. End the TMUX session, if chosen, on detach

_Usage_

```
[bash] ./erase_drives.sh [drives_override] [session_suffix] [end_on_detach]
```

_Options_

| Option Flag |                          Description                           |
|    :---:    |                             :---:                              |
|     N/A     |                              N/A                               |

_Parameters_

|         Parameter         |                   Description                    |
|           :---:           |                      :---:                       |
|      Drives Override      |           Array of drive IDs to erase            |
|      Session Suffix       |        Suffix to add to the session name         |
|       End On Detach       |  End process when the TMUX session is detached   |

_Examples_

* **./erase_drives.sh** "/dev/da0 /dev/da1 /dev/da2"
* **./erase_drives.sh** "/dev/da0 /dev/da1 /dev/da2" "session2"
* **./erase_drives.sh** "/dev/da0 /dev/da1 /dev/da2" "session2" true

_Drives Tested_

|        Status        |                       Component                       |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |                   WD Red Plus (8TB)                   |
|  :white_check_mark:  |                   WD Red Plus (6TB)                   |
|  :white_check_mark:  |                     WD Red (6TB)                      |
|  :white_check_mark:  |                   WD Red Plus (3TB)                   |
|  :white_check_mark:  |                  Kingston 240GB A400                  |

#### erase_drive.sh

A script to begin a drive erase for a single drive.

The following steps will be performed:
1. Pull drive info and display it
2. HDD/SSD Specific Steps
    1. HDD
        1. Run a pass with a RANDOM pattern
        2. Run a pass with a RANDOM pattern
        3. Run a pass with a ZERO pattern
    2. SSD
        1. Run a pass with a RANDOM pattern
        2. Run a pass with a RANDOM pattern
        3. Run a pass with a ZERO pattern
3. Pull drive info and display it

_Usage_

```
[bash] ./erase_drive.sh <drive>
```

_Options_

| Option Flag |                          Description                           |
|    :---:    |                             :---:                              |
|     N/A     |                              N/A                               |

_Parameters_

|         Parameter         |                   Description                    |
|           :---:           |                      :---:                       |
|           Drive           |                  Drive to erase                  |

_Examples_

* **./erase_drive.sh** "/dev/da3"

_Drives Tested_

|        Status        |                       Component                       |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |                   WD Red Plus (8TB)                   |
|  :white_check_mark:  |                   WD Red Plus (6TB)                   |
|  :white_check_mark:  |                     WD Red (6TB)                      |
|  :white_check_mark:  |                   WD Red Plus (3TB)                   |
|  :white_check_mark:  |                  Kingston 240GB A400                  |

## Deployment

This section provides additional notes about how to deploy this on a live 
system.

## Dependencies

* [Utility-Scripts](https://github.com/jhthorp/Utility-Scripts) - A collection 
of utility scripts.

## Notes

This project does not contain any additional notes at this time.

## Test Environments

### Operating System Compatibility

|        Status        |                        System                         |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |                     MacOS 11.2.x                      |
|  :white_check_mark:  |                     MacOS 11.1.x                      |
|  :white_check_mark:  |                     MacOS 11.0.x                      |
|  :white_check_mark:  |                   TrueNAS 12.0-U2.1                   |
|  :white_check_mark:  |                    TrueNAS 12.0-U2                    |
|  :white_check_mark:  |                   TrueNAS 12.0-U1.1                   |
|  :white_check_mark:  |                    TrueNAS 12.0-U1                    |
|  :white_check_mark:  |                 TrueNAS 12.0-RELEASE                  |
| :information_source: |                TrueNAS < 12.0-RELEASE                 |
| :information_source: |            FreeNAS < TrueNAS 12.0-RELEASE             |

### Hardware Compatibility

|        Status        |                       Component                       |
|        :---:         |                         :---:                         |
|  :white_check_mark:  |              MacBook Pro (15-inch, 2018)              |

## Contributing

Please read [CODE_OF_CONDUCT](.github/CODE_OF_CONDUCT.md) for details on our 
Code of Conduct and [CONTRIBUTING](.github/CONTRIBUTING.md) for details on the 
process for submitting pull requests.

## Support

Please read [SUPPORT](.github/SUPPORT.md) for details on how to request 
support from the team.  For any security concerns, please read 
[SECURITY](.github/SECURITY.md) for our related process.

## Versioning

We use [Semantic Versioning](http://semver.org/) for versioning. For available 
releases, please see the 
[available tags](https://github.com/jhthorp/Drive-Scripts/tags) or look 
through our [Release Notes](.github/RELEASE_NOTES.md). For extensive 
documentation of changes between releases, please see the 
[Changelog](.github/CHANGELOG.md).

## Authors

* **Jack Thorp** - *Initial work* - [jhthorp](https://github.com/jhthorp)

See also the list of 
[contributors](https://github.com/jhthorp/Drive-Scripts/contributors) who 
participated in this project.

## Copyright

Copyright © 2020 - 2021, Jack Thorp and associated contributors.

## License

This project is licensed under the GNU General Public License - see the 
[LICENSE](LICENSE.md) for details.

## Acknowledgments

* N/A