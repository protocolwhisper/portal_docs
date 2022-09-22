.. Portal documentation master file, created by
   sphinx-quickstart on Wed Aug 31 14:38:46 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. image:: ../images/portal-logo.png
	:width: 300px

|

Introduction
============
Welcome to Portal's Documentation!
----------------------------------

Portal is a next-generation blockchain oracle service. We offer users private, scalable, and fast compute power at low costs. Since oracle services operate outside the trusted blockchain, they must provide integrity through other means. Portal utilizes the latest advancements in confidential computing and trusted hardware to achieve verifiable off-chain computations on any blockchain. 

Like a Function-as-a-Service or a trusted API, we allow Dapp developers to extend existing smart contracts by making off-chain calls to perform computations that may require more resources than are available on-chain (i.e., gas) or may require privacy.

One of Portal's goals is to be interoperable, not only in terms of L1 and L2 integrations but also in terms of catering to developers' needs.
Portal is not bound to any specific programming language, meaning our users can write code in their preferred language instead of learning a brand-new one. 

Portal enables use cases from complex DeFi strategies, data analytics, artificial intelligence, and gaming engines to private NFTs and auctions, all accessible via our easy-to-use interfaces, integrated across various popular blockchains.

Portal also has a currency, PRTL, which powers our ecosystem. We envision anyone can monetize the latent compute power of their compatible devices by participating as a decentralized oracle node to service the future of Web3.



Overview
---------------
In the next section, we outline a technical tutorial and demo on how developers can use our smart contracts, currently running on EVM-compatible blockchains. The Verifiable Random Function (VRF) demo (`available on Remix <https://remix.ethereum.org/#url=https://github.com/PortalCompute/portal_docs/blob/main/sample_code/VRFClient.sol>`_) helps you to understand our architecture, request Testnet PRTL from our faucet, and start using our VRF service and smart contracts to power your Dapps. We will be releasing more heavy compute-oriented demos as we continue development. 

Since we are building Portal from the ground up, feel free to regularly check for updates and follow us on `Twitter <https://twitter.com/portalcompute>`_ for the latest news about Portal.



.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Getting Started
   
   self
   user-vrf-docs.rst

   