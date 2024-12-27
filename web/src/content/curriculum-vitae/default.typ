#let name = "David Wood"

#set document(
  title: name + "'s Curriculum Vitae",
  author: name
)
#set text(font: "Austera Text", size: 10pt, lang: "en")
#set page(
  footer: text(8pt, fill: gray)[
    #grid(
      columns: (1fr, 1fr, 1fr),
      {
        let fmt = "[month repr:long] [day], [year]"
        align(left)[
          Generated #datetime.today().display(fmt)
        ]
      },
      align(center)[#(name)'s Curriculum Vitae],
      align(right, counter(page).display()),
    )
  ],
  margin: (
    top: 1.5cm,
    bottom: 2cm,
    left: 2cm,
    right: 2cm
  )
)
#set list(tight: false, indent: 5mm)
#set par(leading: 0.45em)

#show heading: it => [
  #set text(10pt, weight: "light")
  #pad(bottom: 0.5mm)[
    #pad(top: 0pt, bottom: -10pt, it.body)
    #line(length: 100%, stroke: 0.25pt)
  ]
]
#show link: it => [
  #underline(stroke: 0.1mm + gray, offset: 0.75mm, it.body)
]

#let title(
  name: "",
  subtitles: ()
) = {
  align(center)[
    #block(text(weight: "light", 2.5em, name))
    #subtitles.join(" · ")
  ]
}

#let entry(
  body,
) = {
  pad(
    top: 0.1mm,
    bottom: 0.1mm,
    left: 5mm,
    right: 5mm,
    {
      body
    }
  )
}

#let exp(
  body,
  title: "",
  subtitle: "",
  location: "",
  period: ""
) = {
  entry({
    grid(
      columns: (auto, 1fr),
      row-gutter: 2mm,
      align(left, strong(title)),
      align(right, text(gray, location)),
      align(left, emph(subtitle)),
      align(right, text(gray, period))
    )
    body
  })
}

#let prev(
  title: "",
  period: ""
) = {
  entry({
    grid(
      columns: (1fr),
      rows: (auto, auto),
      row-gutter: 2mm,
      align(center, text(size: 8pt, fill: gray, title)),
      align(center, text(size: 8pt, fill: silver, period)),
    )
  })
}

#title(
  name: name,
  subtitles: (
    "Software Engineer",
    "Edinburgh, Scotland",
    link("mailto:hello@davidtw.co")[hello#(sym.at)davidtw.co],
    link("https://davidtw.co")[https://davidtw.co],
    link("https://github.com/davidtwco")[#(sym.at)davidtwco],
  )
)

= Open Source
#exp(
  title: "Rust Programming Language",
  subtitle: "Compiler Team Co-Lead",
  location: "",
  period: "Aug 2023 - Present",
)[
  In collaboration with my compiler team co-lead, I’m responsible for representing the Rust compiler
  team; owning the compiler team’s decisions; making unilateral approval for trivial or urgent
  issues; driving the team’s weekly meetings; communicating with other members of Rust leadership;
  authoring communication on behalf of the team; and supporting compiler team members in their
  contributions.

  Since becoming co-lead, I have #link("https://borrowed.dev/p/priorities-plans-and-backlogs")[
  created a roadmap for my term as co-lead based on team member feedback], landed an RFC to
  #link("https://github.com/rust-lang/rfcs/pull/3599")[restructure the compiler team], improved
  review queue capacity, and written about the team's
  #link("https://borrowed.dev/p/on-ongoing-work-in-the-rust-compiler-team")[ongoing work],
  #link("https://borrowed.dev/p/priorities-plans-and-backlogs")[review queue], and the
  #link("https://borrowed.dev/p/priorities-plans-and-backlogs")[project's structure].
]

#exp(
  title: "Rust Programming Language",
  subtitle: "Compiler Team Maintainer",
  location: "",
  period: "Oct 2017 - Present",
)[
  As member of the Rust compiler team, I am responsible for the implementation and maintenance of
  the Rust compiler, which involves having merge privileges; being assigned patches to review;
  fixing high-priority bugs; and reviewing backports, major change proposals and compiler RFCs.

  I regularly contribute bug fixes, diagnostic improvements and refactorings; as well as lead or
  contribute to engineering efforts to implement new features in the Rust compiler. Since starting
  to contribute to Rust, I have been involved in various working groups, including: async/await,
  diagnostics, debuginfo, meta, polymorphization and non-lexical lifetimes.
]

= Work Experience
#exp(
  title: "Arm Holdings plc",
  subtitle: "Staff Software Engineer, Rust Team Lead",
  location: "Edinburgh, Scotland",
  period: "September 2024 - Present"
)[
  Within the Rust team at Arm, we contribute improved Arm platform support to the upstream Rust
  project and ecosystem, prioritising requests from our partners with Rust workloads; and perform
  internal research on the advantages and impact of potential and upcoming architecture features
  on Rust workloads. As lead of the team, I am responsible for:

  #list(
    [mentoring and line management of team members, helping them achieve their goals and succeed
     in the team and company],
    [the team's relationship with the upstream Rust project, building community consensus around our
     objectives and owning Arm's commitments to upstream],
    [representing Arm within the Rust community at conferences and upstream project events],
    [planning the team's work, establishing and communicating our priorities and roadmap to
     leadership],
    [ensuring the team is high-performing and achieving its objectives],
    [sharing Rust knowledge and expertise internally],
    [my own engineering contributions to our ongoing projects, such as
     #link("https://github.com/rust-lang/rfcs/pull/3729")[extending the language to be able to
     support the Arm scalable vector extension]],
  )
]

#exp(
  title: "Huawei Technologies Research & Development UK Ltd.",
  subtitle: "Senior Software Engineer A, Programming Languages Lab",
  location: "Edinburgh, Scotland",
  period: "November 2022 - August 2024"
)[
  Within the Central Software Institute of Huawei R&D, I leveraged my Rust experience to accelerate
  and guarantee Rust's successful adoption, involving:

  #list(
    [contributions to the upstream Rust compiler, prioritising features and bugs which impacted
     Huawei's business units],
    [directly working with internal customers to recognise Rust opportunities, advising and
     assisting teams adopting Rust, and identifying and prioritizing requirements for upstream
     contributions],
    [supporting HQ colleagues in maintaining the internal toolchain],
    [knowledge sharing of Rust compiler internals],
    [participation in Huawei's Technical Management Committee to define internal coding standards
     for Rust],
    [internally representing the Edinburgh Research Centre within Huawei by promoting my work in
     company publications and presenting to leadership from other parts of the organisation],
    [externally representing Huawei by speaking at international conferences and attending as a
     sponsor],
  )

  I was awarded Huawei's "President Award of the 2012 Laboratories", "President's Award of the
  European Academy", "Gold Team Award", "Innovation Spark Award", and "Future Star" awards.
]

#exp(
  title: "Huawei Technologies Research & Development UK Ltd.",
  subtitle: "Senior Software Engineer B, Programming Languages Lab",
  location: "Edinburgh, Scotland",
  period: "Aug 2021 - Nov 2022"
)[]

#exp(
  title: "Codeplay Software Ltd.",
  subtitle: "Senior Software Engineer, Infrastructure",
  location: "Edinburgh, Scotland",
  period: "Nov 2020 - Aug 2021"
)[
  I was the primary maintainer of Codeplay's continuous integration infrastructure and led the
  effort to rebuild the core infrastructure with NixOps to improve reproducibility.

  In addition, I worked as a compiler engineer on SYCL support for NVIDIA GPUs which was contributed
  to Intel's DPC++. I implemented driver support in Clang for the `nvptx64-nvidia-nvcl-sycldevice`
  target, target-specific passes in LLVM, builtins in libclc, and various bug fixes to LLVM, Clang
  and the LLVM-SPIRV translator.
]

#exp(
  title: "Codeplay Software Ltd.",
  subtitle: "Software Engineer, Infrastructure",
  location: "Edinburgh, Scotland",
  period: "Sep 2017 - Nov 2020"
)[]

#exp(
  title: "Codeplay Software Ltd.",
  subtitle: "Intern Build Engineer",
  location: "Edinburgh, Scotland",
  period: "May 2017 - Sep 2017"
)[
  I rebuilt the Codeplay's continuous integration infrastructure during my internship - introducing
  automated re-provisioning of build nodes and improving configuration management, reducing the
  turn-around time of changes requested by engineering teams and downtime which impacted
  engineering productivity.
]

#prev(
  title: [Earlier experience available #link("https://www.linkedin.com/in/davidtwco/")[on LinkedIn]],
  period: "Jun 2014 - Jun 2016, Apr 2015 - Feb 2017, Sep 2018 - Nov 2018"
)

= Education
#exp(
  title: "University of Glasgow",
  subtitle: "MSci Software Engineering with Work Placement, Honours of the First Class",
  location: "Glasgow, Scotland",
  period: "Sep 2015 - Jun 2020"
)[
  I graduated with a GPA of 20.0 (out of a maximum 22.0) and
  #link("https://davidtw.co/media/masters_dissertation.pdf")[completed my MSci project on
  "Polymorphisation"], a code-size optimisation in the Rust compiler to reduce unnecessary
  monomorphisation during code generation. In my first year, I was awarded "Best Computing Science
  Student Intending Single Honours" and in my final year, "Most Outstanding Project in MSci SE WP".
]

#exp(
  title: "Glasgow Caledonian University",
  subtitle: "Nuffield Foundation Placement",
  location: "Glasgow, Scotland",
  period: "May 2014 - Jul 2024"
)[]

= Memberships
#exp(
  title: "Open Source Initiative",
  subtitle: "Individual Membership",
  location: "",
  period: "Feb 2020 - Present"
)[]

= Awards
#exp(
  title: link("https://www.sigplan.org/Awards/Software/")[Programming Languages Software Award],
  subtitle: "ACM SIGPLAN",
  location: "Copenhagen, Denmark",
  period: "Jun 2024"
)[]

= Conference Speaking
#exp(
  title: "QCon",
  subtitle: "Split DWARF in rustc",
  location: "Shanghai, China",
  period: "Nov 2022"
)[]
