import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberwale/src/info/presentation/widgets/legal_page_ui.dart';

class _Highlight {
  const _Highlight(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}

const _highlights = <_Highlight>[
  _Highlight(
    Icons.gavel_outlined,
    'Legally Binding',
    'By accessing Numberwale, you agree to follow DOT, TRAI, and platform '
        'terms.',
  ),
  _Highlight(
    Icons.verified_user_outlined,
    'Secure Processing',
    'All identity details and documentation are handled strictly per '
        'security guidelines.',
  ),
  _Highlight(
    Icons.account_balance_outlined,
    'Jurisdiction',
    'Any purchase or registration issues fall under Thane/Mumbai courts '
        'jurisdiction.',
  ),
  _Highlight(
    Icons.cloud_done_outlined,
    'Digital Delivery',
    'Simcard and custom advisory products are intangible digital bookings '
        'and delivery.',
  ),
];

class _Subsection {
  const _Subsection({this.subtitle, required this.content, this.list});

  final String? subtitle;
  final String content;
  final List<String>? list;
}

class _Section {
  const _Section({required this.title, this.content, this.subsections});

  final String title;
  final List<String>? content;
  final List<_Subsection>? subsections;
}

const _sections = <_Section>[
  _Section(
    title: "Introduction",
    content: [
      "THIS AGREEMENT IS AN ELECTRONIC DOCUMENT IN TERMS OF THE INFORMATION TECHNOLOGY ACT, 2000 AND RULES MADE THERE UNDER AND THE AMENDED PROVISIONS PERTAINING TO ELECTRONIC DOCUMENTS/ RECORDS IN VARIOUS STATUTES AS AMENDED BY THE INFORMATION TECHNOLOGY ACT, 2000. THIS AGREEMENT DOES NOT REQUIRE ANY PHYSICAL, ELECTRONIC OR DIGITAL SIGNATURE.",
      "THE AGREEMENT IS A LEGALLY BINDING DOCUMENT BETWEEN YOU AND NUMBERWALE (BOTH TERMS DEFINED BELOW). THE TERMS OF THIS AGREEMENT WILL BE EFFECTIVE UPON YOUR ACCEPTANCE OF THE SAME (DIRECTLY OR INDIRECTLY IN ELECTRONIC FORM OR BY MEANS OF A N ELECTRONIC RECORD) AND WILL GOVERN THE RELATIONSHIP BETWEEN USER AND NUMBERWALE FOR THE USE OF THE WEBSITE (DEFINED BELOW)",
      "THIS DOCUMENT IS PUBLISHED AND SHALL BE CONSTRUED IN ACCORDANCE WITH THE PROVISIONS OF RULE 3(I) OF INFORMATION TECHNOLOGY (INTERMEDIARIES GUIDELINES) RULE, 2011 UNDER INFORMATION TECHNOLOGY ACT, 2000 THAT REQUIRE PUBLISHING THE RULES AND REGULATIONS PRIVACY POLICY AND USER AGREEMENT FOR ACCESS OR USAGE OF THE WEBSITE.",
      "PLEASE READ THESE TERMS AND CONDITIONS CAREFULLY BEFORE USING OR REGISTERING ON THE WEBSITE OR ACCESSING ANY MATERIAL INFORMATION OR SERVICES THROUGH THE WEBSITE IF YOU DO NOT AGREE WITH THESE TERMS AND CONDITIONS, PLEASE DO NOT USE THE WEBSITE",
    ],
    subsections: null,
  ),
  _Section(
    title: "Definitions",
    content: [
      "<strong>Promoter:</strong> Numberwale, a proprietorship company incorporated under the Companies Act, 1956, with its registered office at Office No. 005, Building No. 12, Sangeet Complex, Jesal Park, Bhayander (East), Thane.",
      "Maharashtra - 401105 Website:- The domain name www.numberwale.com ( hereinafter referred to as 'Website') owned & managed by Numberwale User:- An End User or a customer who wishes to avail services from our Website. Government Agency:- TRAI & DOT Jurisdiction:- The Courts of Thane alone should have Exclusive Jurisdiction Arbitration:- Appointment of Arbitrator shall be in accordance with Arbitration & Concillation Act, 1996.",
      "These Terms of Use of the website located at the URL www.numberwale.com (the Website) are between Numberwale (hereinafter referred to as 'Numberwale' or 'We' or 'Us' or 'Our') and the guest users or registered users of the Website (hereinafter referred to as 'You' or 'Your' or 'Yourself' or 'User') and describe the terms on which Numberwale offers You access to the Website and such other services.",
    ],
    subsections: null,
  ),
  _Section(
    title: "1. General",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "1.1",
        content:
            "We invite you to visit the site at your convenience. However, being allowed to access the site, you bind yourself into this USER AGREEMENT that contains terms and conditions as set out hereinafter. Please note that by accessing and browsing the site, you acknowledge that you have read the terms and conditions on this site, as well as all other policies described in the site and that you accept and agree to be bound by the same, without limitation or qualification. If you do not accept the terms and conditions let down in this user agreement, do not use this website.",
        list: null,
      ),
      _Subsection(
        subtitle: "1.2",
        content:
            "numberwale shall not be required to notify you, whether as a registered user or not, of any changes made to the Terms of Use. The revised Terms of Use shall be made available on the Website. Your use of the Website and the Services is subject to the most current version of the Terms of Use made available on the Website at the time of such use. You are requested to regularly visit the homepage www.numberwale.com to view the most current Terms of Use.",
        list: null,
      ),
      _Subsection(
        subtitle: "1.3",
        content:
            "By using this Website or any facility or Service provided by this Website in any way; or merely browsing the Website, You agree that you have read, understood and agreed to be bound by these Terms of Use and the Website's Privacy Policy available at the homepage, www.numberwale.com.",
        list: null,
      ),
      _Subsection(
        subtitle: "1.4",
        content:
            "Numberwale agrees to deliver the merchandise ordered by you only at such locations as per the Order Confirmation Form. numberwale shall not be liable to deliver any merchandize or Services purchased by Users for delivery in locations outside India shall not be entertained.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "2. About Us",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "2.1",
        content:
            "Numberwale is a reseller & online marketplace of the products and services offered, and do not take the warranty/ Insurance / Guarantee of the services and tariffs provided by the Telcom service providers/ Telcom's. Numberwale provides the Recharge / Connection / Numbers on the terms and conditions as prescribed by the Telcom service provider, and strictly follows the TRAI & DOT norms for Activation / Recharging the SIM. Any dispute with regard to the Service or Tariff related to Telcom service provider’s end, User has to directly deal with the Telcom service provider as any change in the Telcom service provider/ Telcom's policy is not under the control of numberwale and numberwale is only a window for the End User to get the products and Services under one roof.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "3. Membership Eligibility",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "3.1",
        content:
            "Use of the Website is available only to persons as Specific under Indian Contract Act, 1872. Persons not having Contract capacity with the Indian Contract Act, 1872 are not eligible to use the Website.If you are a minor i.e. under the age of 18 years, you shall not register as a User of the numberwale.com website and shall not transact on or use the website. As a minor if you wish to use or transact on website, such use or transaction may be made by your legal guardian or parents on the Website. Numberwale reserves the right to terminate your membership and / or refuse to provide you with access to the Website if it is brought to numberwale's notice or if it is discovered that you are under the age of 18 years.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "4. User Account Password & Security",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "4.1",
        content:
            "Numberwale makes the Services available to You through the Website only if You have provided numberwale certain required User information and created an account ('Account') through numberwale login ID and password or other log-in ID and password, which can include a facebook, gmail, yahoo ID or any other valid email ID (collectively, the 'Account Information').",
        list: null,
      ),
      _Subsection(
        subtitle: "4.2",
        content:
            "The Website requires You to register as a User by creating an Account in order to avail of the Services provided by the Website. You will be responsible for maintaining the confidentiality of the Account Information, and are fully responsible for all activities that occur under Your Account. You agree to immediately notify numberwale of any unauthorized use of Your Account Information or any other breach of security, and ensure that You exit from Your Account at the end of each session. numberwale cannot and will not be liable for any loss or damage arising from Your failure to comply. You may be held liable for losses incurred by numberwale or any other user of or visitor to the Website due to authorized or unauthorized use of Your Account as a result of Your failure in keeping Your Account Information secure and confidential.",
        list: null,
      ),
      _Subsection(
        subtitle: "4.3",
        content:
            "The Website also allows restricted access to the Services for unregistered Users.",
        list: null,
      ),
      _Subsection(
        subtitle: "4.4",
        content:
            "You shall ensure that the Account Information provided by You in the Website's registration form is complete, accurate and up-to-date. Use of another user's Account Information for availing the Services is expressly prohibited.",
        list: null,
      ),
      _Subsection(
        subtitle: "4.5",
        content:
            "If You provide any information that is untrue, inaccurate, not current or incomplete (or becomes untrue, inaccurate, not current or incomplete), or numberwale has reasonable grounds to suspect that such information is untrue, inaccurate, not current or incomplete, numberwale has the right to suspend or terminate Your Account and refuse any and all current or future use of the Website (or any portion thereof).",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "5. Communications",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "5.1",
        content:
            "When you use the Website or send emails or other data, information or communication to us, You agree and understand that You are communicating with Us through electronic records and You consent to receive communications via electronic records from Us periodically and as and when required. We may communicate with you by email or by such other mode of communication, electronic or otherwise.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "6. Usage Conduct",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "6.1",
        content:
            "You shall solely be responsible for maintaining the necessary computer equipments and Internet connections that may be required to access, use and transact on the Website. You are also under an obligation to use this Website for reasonable and lawful purposes only, and shall not indulge in any activity that is not envisaged through the Website. You shall use this Website, and any voucher/ coupons purchased through it, for personal, non-commercial use only and shall not re-sell the same to any other person. numberwale shall be under no liability whatsoever in respect of any loss or damage arising directly or indirectly out of the decline of authorization for any transaction, on account of you/cardholder having exceeded the preset limit mutually agreed by numberwale with our acquiring bank from time to time.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "7. Pricing",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "7.1",
        content:
            "All the prices stated on our website are in Indian Rupees & selling price on the product is inclusive of service taxes & Delivery charges unless specified separately. The selling price of mobile numbers are inclusive of activation charges, sim cost, mobile number cost, unique number surcharge (if any), documents processing charges & offerscoupons (if any).",
        list: null,
      ),
      _Subsection(
        subtitle: "7.2",
        content:
            "Promoter solely has the right to define mobile numbers & decide its selling price which depends on various properties under the categories namely Prepaid / Postpaid / RTP & subcategories General/Fancy /MNP displayed on its website www.numberwale.com.",
        list: null,
      ),
      _Subsection(
        subtitle: "7.3",
        content:
            "Numberwale strives to provide you with the best prices possible on products and services you buy or avail of from the Website. However, numberwale does not guarantee that the prices will be the lowest in the city, region or geography. Prices and availability are subject to change without notice or any consequential liability to You.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "8. Billing & Payment",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "8.1",
        content:
            "The Promoter reserves the right to cancel, alter or Modify the order at any time before the activation of the number booked, by refunding the booking amount through the payment mode the payment has been received, as the number activation depends on third party and the Domain doesn't guarantee the activation of the number purchased through them, if any of the dispute / problem regarding activation persists than the User is been redirected to the third party and the Promoter will not be liable for the same.",
        list: null,
      ),
      _Subsection(
        subtitle: "8.2",
        content:
            "We process Payments through COD (Cash On Delivery only in Mumbai) mode & Credit/Debit card , Net banking on all our products which are processed by Third Party Payment Gateway providers. A receipt of the payment would be provided to the user either in Electronic form or as a hard copy.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "9. User Obligations",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "9.1",
        content:
            "Subject to compliance with the Terms of Use, numberwale grants You a non- exclusive, limited privilege to access and use this Website and the Services provided therein.",
        list: null,
      ),
      _Subsection(
        subtitle: "9.2",
        content:
            "You agree to use the Services, Website and the materials provided therein only for purposes that are permitted by: (a) the Terms of Use; and (b) any applicable law, regulation or generally accepted practices or guidelines in the relevant jurisdictions.",
        list: null,
      ),
      _Subsection(
        subtitle: "9.3",
        content:
            "You agree not to access (or attempt to access) the Website and the materials or Services by any means other than through the interface that is provided by numberwale. You shall not use any deep-link, robot, spider or other automatic device, programme, algorithm or methodology, or any similar or equivalent manual process, to access, acquire, copy or monitor any portion of the Website or Content (as defined below), or in any way reproduce or circumvent the navigational structure or presentation of the Website, materials or any Content, to obtain or attempt to obtain any materials, documents or information through any means not specifically made available through the Website.",
        list: null,
      ),
      _Subsection(
        subtitle: "9.4",
        content: "Further, Your undertake not to",
        list: [
          "Defame, abuse, harass, threaten or otherwise violate the legal rights of others;",
          "Impersonate any person or entity, or falsely state or otherwise misrepresentation affiliation with person or entity",
          "Publish, post, upload, distribute or disseminate any inappropriate, profane, defamatory, Infringing, obscene, indecent or unlawful topic, name, material or information through any bookmark, tag or keyword",
          "Upload files that contain software or other material protected by applicable intellectual property laws unless You own or control the rights thereto or have received all necessary consents;",
          "Upload or distribute files that contain viruses, corrupted files, or any other similar software or programs that may damage the operation of the Website or another's computer;",
          "Engage in any activity that interferes with or disrupts access to the Website or the Services (or the servers and networks which are connected to the Website);",
          "Attempt to gain unauthorized access to any portion or feature of the Website, any other systems or networks connected to the Website, to any numberwale server, or to any of the Services offered on or through the Website, by hacking, password mining or any other illegitimate means;",
          "Probe, scan or test the vulnerability of the Website or any network connected to the Website, nor breach the security or authentication measures on the Website or any network connected to the website. You may not reverse look-up, trace or seek to trace any information on any other user, of or visitor to, the Website, or any other customer of numberwale, including any numberwale account not owned by You, to its source, or exploit the Website or Service or information made available or offered by or through the Website, in any way whether or not the purpose is to reveal any information, including but not limited to personal identification information, other than Your own information, as provided for by the Website;",
          "Disrupt or interfere with the security of, or otherwise cause harm to, the Website, systems resources, accounts, passwords, servers or networks connected to or accessible through the Websites or any affiliated or linked sites;",
          "Collect or store data about other users in connection with the prohibited conduct and activities set fort h in this Section.",
          "Use any device or software to interfere or attempt to interfere with the proper working of the website or any transaction being conducted on the Website, or with any other person's use of the website;",
          "Use the Website or any material or Content for any purpose that is unlawful or prohibited by these Terms of Use, or to solicit the performance of any illegal activity or other activity which infringes the rights of numberwale or other third parties;",
          "Conduct or forward surveys, contests, pyramid schemes or chain letters;",
          "Download any file posted by another user of a Service that you know, or reasonably should know, cannot be legally distributed in such manner;",
          "Falsify or delete any author attributions, legal or other proper notices or proprietary designations or labels of the origin or source of software or other material contained in a file that is uploaded;",
          "Violate any code of conduct or other guidelines, which may be applicable for or to any particular service.",
          "Violate any applicable laws or regulations for the time being in force within or outside India",
          "Reverse engineer, modify, copy, distribute, transmit, display, perform, reproduce, publish, license, create derivative works from, transfer, or sell any information or software obtained from the website.",
        ],
      ),
    ],
  ),
  _Section(
    title: "10. Ownership & Property Rights",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "10.1",
        content:
            "Copyright in this Website belongs to Numberwale & its brand. Numberwale also uses contents of their vendors and third parties as well who might not be the original owners of copyright therein. The users should assume that standard copyright protection applies to all materials and contents displayed on the Website. Any redistribution, modification or reproduction of part or all of the contents featured in the Website in any form is prohibited. You may display, print, or download the contents to a local hard disk extracts for your personal, non-commercial use, but only if you acknowledge the Website as the source of the material. You are not permitted, except with the express written consent of Numberwale, to distribute or commercially exploit the contents on this Website. You are also prohibited from transmitting the contents or storing it in any other Website or in other form of electronic retrieval system.",
        list: null,
      ),
      _Subsection(
        subtitle: "10.2",
        content:
            "The Website and the processes, and their selection and arrangement, including but not limited to all text, graphics, user interfaces, visual interfaces, sounds and music (if any), artwork and computer code (collectively, the 'Content') on the Website is owned and controlled by numberwale and the design, structure, selection, coordination, expression, look and feel and arrangement of such Content is protected by copyright, patent and trademark laws, and various other intellectual property rights.",
        list: null,
      ),
      _Subsection(
        subtitle: "10.3",
        content:
            "The trademarks, logos and service marks displayed on the Website ('Marks') are the property of numberwale or their vendors or respective third parties. You are not permitted to use the Marks without the prior consent of numberwale, the vendor or the third party that may own the Marks. You acknowledge and agree that You shall not copy, republish, post, display, translate, transmit, reproduce or distribute any Content through any medium without obtaining the necessary authorization from numberwaler or thirty party owner of such Content.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "11. Documentation and Delivery",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "11.1",
        content:
            "numberwale does not activate any Simcard unless & untill full Documents which are mandatory such as 1 Passport size Photo, 1 copy of Proof of Identity (POI), 1 copy of Proof of address (POA) along with Duly Signed CAF (customer application form) is received by us. You are therefore guided to Submit Valid Photo ID & Address Proof to our executive during delivery of simcard",
        list: null,
      ),
      _Subsection(
        subtitle: "11.2",
        content:
            "You are advised to Sign all The indications Marked on CAF (customer application form) & self attest POI (Proof of Identity) & POA (Proof of Address) before submission to our executive.",
        list: null,
      ),
      _Subsection(
        subtitle: "11.3",
        content:
            "Always Stick your Photograph on CAF Rather than stapling it, any loss due to this would lead to Rejection moreover you would be advised to resubmit your document which may lead to delay in activation of your number, numberwale is not responsible for such delay or Loss",
        list: null,
      ),
      _Subsection(
        subtitle: "11.4",
        content:
            "numberwale reserves the right to Reject the document if found Fake / untrue or incorrect as per the DOT & Telecom service providers norms, We strictly follow all rules laid by TRAI & DOT for document processing however the activation of mobile number takes place at third party locations & therefore numberwale has no control over your personal documents after submission to third party agencies authorized by telecom service providers. numberwale shall not be held responsible in such conditions.",
        list: null,
      ),
      _Subsection(
        subtitle: "11.5",
        content:
            "If there is any Document Rejection from our End or Telecom companies Reject it at there End you will be informed via mail or Sms or Phone call & would be asked to Resubmit the Documents at the earliest, numberwale would not be responsible for Delay in Activation of your Sim Card due to the above.",
        list: null,
      ),
      _Subsection(
        subtitle: "11.6",
        content:
            "numberwale has limited liability only till the Sim card gets activated & services to your number get started. numberwale does not have any liability over raised Tariffs or poor network etc.. after the services have been started by the Provider such problems should be solved by the respective Telecom Service Providers. We Process all your documents (filling it up & Verifying) as per the guidelines raised by Telecom's. Further rejection of Documents and Deactivation of services are looked after by the respective Telecom service provider.",
        list: null,
      ),
      _Subsection(
        subtitle: "11.7",
        content:
            "You are Advised not to Fill the CAF as any mistake in filling would lead to Rejection of Document, our Data entry operators are well trained to look after your CAF fill up needs.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "12. Delivery",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "12.1",
        content:
            "We deliver the Simcard & other products through a Third Party courier company & Our own delivery Team, You are guided to mention correct and detailed Shipping & billing address to avoid delay in services",
        list: null,
      ),
      _Subsection(
        subtitle: "12.2",
        content:
            "We deliver Goods to serviceable locations as mentioned in the booking form within 36 hrs of booking, however there may be delay in delivery of products due to un natural or accidental happenings not under control of numberwale, you are advised to be patient as we update you about the status of your order.",
        list: null,
      ),
      _Subsection(
        subtitle: "12.3",
        content:
            "As soon as your Sim card gets delivered, you will have to prepare all your documents & return them duly signed to our Executive who will verify those with the originals if found true your documents shall then be submitted to operator / Telecom service provider for activation.",
        list: null,
      ),
      _Subsection(
        subtitle: "12.4",
        content:
            "Please note that the Sim card we Deliver is Person Specific & we would require the Person to appear in physical to receive the order. So if you have Placed the Order make sure you are available at your shipping location to receive it or else the Shipment would be returned and our executive will retry to deliver it again by contacting you failure to which your booking will get cancelled & you would then have to make a fresh request with us. Please contact our Support team for any help at support@numberwale.com",
        list: null,
      ),
      _Subsection(
        subtitle: "12.5",
        content:
            "Once payment Receive for the Number, that number will be hold only for 10 Days. If in case there is no contact with the Customer. Hence we have rights to resell the number and we will refund or provide with other vanity number. Once customer is contacted.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "13. Limitation of Liability",
    content: null,
    subsections: [
      _Subsection(
        subtitle: "13.1",
        content:
            "Numberwale shall not be held responsible for any issues that may arise in connection with the use of third-party applications. While we strive to provide a seamless experience, we cannot guarantee the performance or reliability of such applications.",
        list: null,
      ),
      _Subsection(
        subtitle: "13.2",
        content:
            "Should users encounter any problems while using third-party applications, including but not limited to issues such as WhatsApp OTP problems or difficulties with Telegram or any other social media applications, it is recommended to contact the support team of the specific application for assistance.",
        list: null,
      ),
      _Subsection(
        subtitle: "13.3",
        content:
            "By using our services, you acknowledge and agree that Numberwale shall not be liable for any damages or losses resulting from the use of third-party applications, including any interruptions, errors, or malfunctions.",
        list: null,
      ),
      _Subsection(
        subtitle: "13.4",
        content:
            "In the event that users receive any spam calls or SMS messages on the numbers purchased from Numberwale, it is advised to promptly contact their network operator for assistance. Numberwale shall not be liable for any inconvenience or damages caused by such spam calls or messages and will not provide refunds for them.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14. Numerology Services - Terms & Conditions",
    content: [
      "These Terms & Conditions ('Terms') govern the use of this website and all numerology services offered by Numberwale ('Company', 'we', 'our', 'us').",
      "By accessing this website or purchasing our services, you agree to be legally bound by these Terms in accordance with the laws of India.",
    ],
    subsections: null,
  ),
  _Section(
    title: "14.1 Eligibility",
    content: ["By using this website, you confirm that:"],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "You are at least 18 years old;",
          "You are legally competent to enter into a binding contract under the Indian Contract Act, 1872;",
          "You are not prohibited under any applicable law from using our services.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.2 Nature of Services",
    content: [
      "We provide personalized digital services including but not limited to:",
    ],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Numerology reports",
          "Name correction analysis",
          "Business numerology guidance",
          "Personal consultations",
          "Spiritual advisory services",
        ],
      ),
      _Subsection(
        subtitle: null,
        content:
            "All services are customized and delivered digitally via email, WhatsApp, video consultation, or other electronic modes.",
        list: null,
      ),
      _Subsection(
        subtitle: null,
        content:
            "These services fall under digital services and are intangible in nature.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14.3 No Guarantee of Outcomes",
    content: [
      "Numerology is a spiritual and interpretative practice.",
      "All guidance, suggestions, and reports are provided for advisory purposes only.",
      "We do not guarantee specific outcomes relating to:",
    ],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Financial gains",
          "Business growth",
          "Marriage or relationships",
          "Health",
          "Career success",
          "Personal transformation",
        ],
      ),
      _Subsection(
        subtitle: null,
        content:
            "Any action taken based on our guidance is solely at your discretion and risk.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14.4 Payments & Pricing",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "All payments must be made in advance.",
          "Prices are listed in INR unless stated otherwise.",
          "We reserve the right to revise pricing at any time without prior notice.",
          "Applicable GST (if registered) shall be charged as per Indian tax laws.",
          "Upon successful payment, you will receive confirmation via email or WhatsApp.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.5 Refund & Cancellation",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Refunds shall be governed strictly by our Refund & Cancellation Policy published on this website.",
          "Due to the personalized digital nature of services, completed services are non-refundable.",
          "By purchasing, you expressly waive any right to claim refund once service delivery has begun.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.6 User Responsibilities",
    content: ["You agree to:"],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Provide accurate and complete information;",
          "Cooperate during consultation scheduling;",
          "Maintain respectful communication;",
          "Not misuse, copy, or distribute the provided report.",
        ],
      ),
      _Subsection(
        subtitle: null,
        content:
            "We are not responsible for errors caused due to incorrect details submitted by you.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14.7 Intellectual Property Rights",
    content: ["All content on this website, including:"],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Reports",
          "Designs",
          "Text",
          "Branding",
          "Logos",
          "Consultation material",
        ],
      ),
      _Subsection(
        subtitle: null,
        content:
            "are the intellectual property of Numberwale and are protected under the Copyright Act, 1957 (India).",
        list: null,
      ),
      _Subsection(
        subtitle: null,
        content:
            "Unauthorized reproduction, resale, or distribution is strictly prohibited and may result in legal action.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14.8 Limitation of Liability",
    content: [
      "To the maximum extent permitted under Indian law:",
      "We shall not be liable for:",
    ],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Any direct, indirect, incidental, or consequential damages",
          "Financial loss",
          "Emotional distress",
          "Business interruption",
          "Loss arising from reliance on guidance provided",
        ],
      ),
      _Subsection(
        subtitle: null,
        content:
            "Our total liability, if any, shall not exceed the amount paid for the specific service.",
        list: null,
      ),
    ],
  ),
  _Section(
    title: "14.9 Chargebacks & Payment Disputes",
    content: [
      "Initiating a chargeback or payment dispute without first contacting us for resolution may be considered misuse of payment systems.",
      "We reserve the right to:",
    ],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Contest such disputes;",
          "Suspend future services;",
          "Initiate legal remedies where necessary.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.10 Privacy & Data Protection",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "We collect personal information solely for service delivery purposes.",
          "Data handling is governed by applicable Indian data protection regulations, including the Information Technology Act, 2000 and related rules.",
          "We do not sell or share personal data except as required by law.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.11 Force Majeure",
    content: [
      "We shall not be liable for delays or failure in performance due to events beyond our reasonable control including:",
    ],
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Natural disasters",
          "Internet failures",
          "Government restrictions",
          "Technical disruptions",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.12 Governing Law & Jurisdiction",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "These Terms shall be governed by the laws of India.",
          "Any disputes arising out of or related to these Terms shall be subject to the exclusive jurisdiction of the courts of Mumbai, Maharashtra.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.13 Amendments",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "We reserve the right to update or modify these Terms at any time.",
          "Continued use of our website constitutes acceptance of revised Terms.",
        ],
      ),
    ],
  ),
  _Section(
    title: "14.14 Belief-Based Service Disclaimer",
    content: [
      "Numerology and spiritual advisory services are based on traditional belief systems and symbolic interpretations and are not scientifically validated methods. Users acknowledge that results and interpretations may vary and are subjective in nature.",
    ],
    subsections: null,
  ),
  _Section(
    title: "14.15 Coupon Codes and Promotional Offers",
    content: null,
    subsections: [
      _Subsection(
        subtitle: null,
        content: "",
        list: [
          "Coupon codes must be entered at checkout and cannot be applied retroactively to previous purchases.",
          "Coupons are non-transferable, have no cash value, and cannot be combined with other offers unless explicitly stated.",
          "Numberwale reserves the right to cancel, modify, or revoke any promotional code at any time without prior notice if fraud or technical errors occur.",
          "In the event of a refund, only the actual discounted amount paid by the customer will be refunded. The coupon value will not be refunded or re-issued.",
        ],
      ),
    ],
  ),
];

/// Renders [text] as a [Text.rich], turning `<strong>...</strong>` markers
/// (the only inline markup present in the source content) into bold spans.
Widget _richText(String text, TextStyle? style) {
  final spans = <TextSpan>[];
  final pattern = RegExp('<strong>(.*?)</strong>', dotAll: true);
  var last = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > last) {
      spans.add(TextSpan(text: text.substring(last, match.start)));
    }
    spans.add(
      TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    last = match.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last)));
  }
  return Text.rich(TextSpan(style: style, children: spans));
}

/// Mirrors the mobile layout of numberwale.com/terms-and-conditions:
/// gradient hero, highlight cards, a sticky section-jump pill bar with
/// scroll-spy, and an expandable/collapsible accordion of all sections.
class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final _expanded = <int>{0};
  final _scrollController = ScrollController();
  final _sectionKeys = List.generate(_sections.length, (_) => GlobalKey());
  int _activeIndex = 0;
  DateTime? _suppressScrollSpyUntil;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final suppressUntil = _suppressScrollSpyUntil;
    if (suppressUntil != null && DateTime.now().isBefore(suppressUntil)) {
      return;
    }
    const threshold = 200.0;
    var active = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final box =
          _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) {
        active = i;
      } else {
        break;
      }
    }
    if (active != _activeIndex) setState(() => _activeIndex = active);
  }

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        _expanded.add(index);
      }
    });
  }

  void _jumpTo(int index) {
    _suppressScrollSpyUntil = DateTime.now().add(
      const Duration(milliseconds: 550),
    );
    setState(() {
      _expanded.add(index);
      _activeIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      final ctx = _sectionKeys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LegalColors.gray50, Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    const LegalHero(
                      icon: Icons.description_outlined,
                      title: 'TERMS & CONDITIONS',
                      subtitle:
                          'Please read these terms carefully. They govern '
                          'your use of Numberwale website and purchase of '
                          'our VIP telecom and advisory products.',
                    ),
                    const SizedBox(height: 24),
                    for (final h in _highlights) ...[
                      LegalHighlightCard(
                        icon: h.icon,
                        title: h.title,
                        description: h.description,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: LegalTocBarDelegate(
                titles: [for (final s in _sections) s.title],
                activeIndex: _activeIndex,
                onTap: _jumpTo,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LegalColors.gray100),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Showing ${_sections.length} sections',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: LegalColors.gray400,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        _PillButton(
                          label: 'Expand All',
                          onTap: () => setState(() {
                            _expanded
                              ..clear()
                              ..addAll(
                                List.generate(_sections.length, (i) => i),
                              );
                          }),
                        ),
                        const SizedBox(width: 8),
                        _PillButton(
                          label: 'Collapse All',
                          onTap: () => setState(_expanded.clear),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < _sections.length; i++)
                    Padding(
                      key: _sectionKeys[i],
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SectionTile(
                        index: i,
                        section: _sections[i],
                        expanded: _expanded.contains(i),
                        active: i == _activeIndex,
                        onTap: () => _toggle(i),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: LegalColors.gray50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: LegalColors.gray600,
          ),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.index,
    required this.section,
    required this.expanded,
    required this.active,
    required this.onTap,
  });

  final int index;
  final _Section section;
  final bool expanded;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.roboto(
      fontSize: 14,
      height: 1.6,
      color: LegalColors.gray600,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: active ? LegalColors.orange200 : LegalColors.gray100,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: active
                ? LegalColors.primary.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  LegalSectionNumber(index),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      section.title,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: LegalColors.gray900,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: expanded
                          ? LegalColors.orange50
                          : LegalColors.gray50,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: expanded
                            ? LegalColors.primary
                            : LegalColors.gray400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: LegalColors.gray100),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.content != null)
                    for (final p in section.content!) ...[
                      _richText(p, bodyStyle),
                      const SizedBox(height: 12),
                    ],
                  if (section.subsections != null)
                    for (final sub in section.subsections!)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 4, bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: LegalColors.gray50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: LegalColors.gray100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sub.subtitle != null) ...[
                              Text(
                                sub.subtitle!,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: LegalColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            _richText(sub.content, bodyStyle),
                            if (sub.list != null) ...[
                              const SizedBox(height: 12),
                              for (final li in sub.list!)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('•  ', style: bodyStyle),
                                      Expanded(child: _richText(li, bodyStyle)),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
