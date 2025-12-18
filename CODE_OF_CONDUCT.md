# Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in TaskFlow a harassment-free experience for everyone, regardless of age, body size, visible or invisible disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

We pledge to act and interact in ways that contribute to an open, welcoming, diverse, inclusive, and healthy community.

## Our Standards

### Examples of behavior that contributes to a positive environment:

- **Being respectful** of differing opinions, viewpoints, and experiences
- **Giving and gracefully accepting** constructive feedback
- **Accepting responsibility** and apologizing to those affected by our mistakes, and learning from the experience
- **Focusing on what is best** not just for us as individuals, but for the overall community
- **Showing empathy** towards other community members
- **Using welcoming and inclusive language**
- **Being collaborative** and supportive

### Examples of unacceptable behavior:

- The use of sexualized language or imagery, and sexual attention or advances of any kind
- Trolling, insulting or derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information, such as a physical or email address, without their explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting
- Dismissing or attacking inclusion-oriented requests

## Project-Specific Standards

### Code Quality

- Write clean, maintainable, and well-documented code
- Follow the established coding standards in [CONTRIBUTING.md](CONTRIBUTING.md)
- Test your code before submitting
- Respect existing architectural decisions unless proposing changes through proper channels

### Collaboration

- **Communication**: Be clear, concise, and professional in all communications
- **Code Reviews**: Provide constructive feedback focused on the code, not the person
- **Respect Time**: Be responsive to questions and reviews when reasonably possible
- **Ask Questions**: No question is too basic - we're all learning

### Issue and PR Guidelines

- Search for existing issues/PRs before creating new ones
- Provide clear descriptions and reproduction steps for bugs
- Include relevant screenshots or videos for UI changes
- Keep discussions focused and on-topic
- Accept decisions gracefully even when you disagree

## Enforcement Responsibilities

Project maintainers are responsible for clarifying and enforcing our standards of acceptable behavior and will take appropriate and fair corrective action in response to any behavior that they deem inappropriate, threatening, offensive, or harmful.

Project maintainers have the right and responsibility to remove, edit, or reject comments, commits, code, wiki edits, issues, and other contributions that are not aligned with this Code of Conduct, and will communicate reasons for moderation decisions when appropriate.

## Scope

This Code of Conduct applies within all project spaces, including:

- GitHub repository (code, issues, pull requests, discussions)
- Project documentation
- Communication channels (if applicable)
- Project-related events or meetings

This Code of Conduct also applies when an individual is officially representing the project in public spaces.

## Reporting

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project maintainers. All complaints will be reviewed and investigated promptly and fairly.

All project maintainers are obligated to respect the privacy and security of the reporter of any incident.

### How to Report

If you experience or witness unacceptable behavior:

1. **Document the incident** including dates, times, and any relevant screenshots
2. **Report to project maintainers** through appropriate channels
3. **Expect acknowledgment** within 48 hours
4. **Confidentiality**: Reports will be kept confidential

## Enforcement Guidelines

Project maintainers will follow these Community Impact Guidelines in determining the consequences for any action they deem in violation of this Code of Conduct:

### 1. Correction

**Community Impact**: Use of inappropriate language or other behavior deemed unprofessional or unwelcome in the community.

**Consequence**: A private, written warning from project maintainers, providing clarity around the nature of the violation and an explanation of why the behavior was inappropriate. A public apology may be requested.

### 2. Warning

**Community Impact**: A violation through a single incident or series of actions.

**Consequence**: A warning with consequences for continued behavior. No interaction with the people involved, including unsolicited interaction with those enforcing the Code of Conduct, for a specified period of time. This includes avoiding interactions in project spaces as well as external channels. Violating these terms may lead to a temporary or permanent ban.

### 3. Temporary Ban

**Community Impact**: A serious violation of community standards, including sustained inappropriate behavior.

**Consequence**: A temporary ban from any sort of interaction or public communication with the project for a specified period of time. No public or private interaction with the people involved, including unsolicited interaction with those enforcing the Code of Conduct, is allowed during this period. Violating these terms may lead to a permanent ban.

### 4. Permanent Ban

**Community Impact**: Demonstrating a pattern of violation of community standards, including sustained inappropriate behavior, harassment of an individual, or aggression toward or disparagement of classes of individuals.

**Consequence**: A permanent ban from any sort of public interaction within the project.

## Academic Integrity

As this is an academic project:

### Expected Conduct

- **Original Work**: Submit only your own work unless properly cited
- **Collaboration**: Collaborate appropriately as allowed by course guidelines
- **Attribution**: Give credit to sources, libraries, and inspirations
- **Honesty**: Be truthful about contributions and understanding

### Prohibited Conduct

- Plagiarism or copying code without attribution
- Misrepresenting your contributions
- Submitting work completed by others as your own
- Violating academic integrity policies of the institution

## Positive Community Examples

### Good Issue Report

```markdown
**Description**: App crashes when uploading large images

**Steps to Reproduce**:
1. Go to profile settings
2. Select "Change Photo"
3. Choose image > 5MB
4. App crashes

**Expected**: Image should be compressed or error shown
**Actual**: App crashes without warning

**Environment**: Android 13, Pixel 6
**Screenshots**: [attached]
```

### Constructive Code Review Comment

```markdown
The logic here works, but we could improve readability:

Consider extracting this validation into a separate method:
\`\`\`dart
bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
\`\`\`

This makes the intent clearer and the method more testable.
```

### Respectful Disagreement

```markdown
I understand your concern about performance, and I appreciate you raising it.

However, I think readability is more important here because:
1. This code runs only on user action (not in loops)
2. The performance difference is negligible (<1ms)
3. Future maintainers will understand it more easily

Would you be comfortable with this approach if we add a comment explaining the trade-off?
```

## Our Commitment

We are committed to:

- **Continuous Improvement**: Regularly reviewing and updating this Code of Conduct
- **Fair Enforcement**: Applying rules consistently and fairly to all community members
- **Open Communication**: Being transparent about decisions affecting the community
- **Welcoming Environment**: Actively creating a space where everyone can contribute
- **Learning**: Recognizing that we all make mistakes and focusing on growth

## Questions or Concerns

If you have questions about this Code of Conduct or its enforcement:

1. Review the [CONTRIBUTING.md](CONTRIBUTING.md) guide
2. Check existing issues/discussions
3. Contact project maintainers
4. Suggest improvements through pull requests

## Attribution

This Code of Conduct is adapted from:
- [Contributor Covenant, version 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html)
- [GitHub's Community Guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
- Academic integrity principles from higher education institutions

## Version

**Version**: 1.0.0  
**Last Updated**: December 9, 2025  
**Effective Date**: December 9, 2025

---

By participating in TaskFlow, you agree to abide by this Code of Conduct.

Thank you for helping make this a welcoming, friendly community for everyone! 🎉
