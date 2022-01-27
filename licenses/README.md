# Licenses used in this firmware

This SDK contains a lot of different applications, libraries and recipes. 
The SDK's license is [GPL-3](../LICENSE)

Here are links to the licenses in the main repos used in this tool
* [Little Kernel bootloader (MIT)](https://github.com/Biktorgj/quectel_lk/blob/master/LICENSE)
* [Linux 3.18.140 kernel](https://github.com/Biktorgj/quectel_eg25_kernel/blob/linux-3.18.140/COPYING)
* [Forked meta-qcom repository](https://github.com/Biktorgj/meta-qcom/blob/honister/COPYING.MIT)

Different components of OpenEmbedded are under different licenses (a mix
of MIT and GPLv2). See LICENSE.GPL-2.0-only and LICENSE.MIT for further 
details of the individual licenses.

All metadata is MIT licensed unless otherwise stated. Source code
included in tree for individual recipes (e.g. patches) are under 
the LICENSE stated in the associated recipe (.bb file) unless 
otherwise stated.

License information for any other files is either explicitly stated 
or defaults to GPL version 2 only.

Individual files contain the following style tags instead of the full license 
text to identify their license:

    SPDX-License-Identifier: GPL-2.0-only
    SPDX-License-Identifier: MIT

This enables machine processing of license information based on the SPDX
License Identifiers that are here available: http://spdx.org/licenses/

You can find the licenses from the different components used in this build [here](./licenses/)