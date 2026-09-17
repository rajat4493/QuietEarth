import SwiftUI

/// Layer 3: "Where this comes from". Never the default view — the practice and
/// its rationale stand on their own without any of this.
struct ProvenanceCard: View {
    let reference: ClassicalReference

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            lineageStrip

            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                Text(reference.citation)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.quietInk.opacity(0.6))

                Text(reference.transliteration)
                    .font(.callout.italic())
                    .foregroundStyle(Color.quietInk.opacity(0.85))
                    .textSelection(.enabled)

                Text(reference.gloss)
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk)

                Text("Our plain-English rendering, not a scholarly translation. \(reference.publicDomainSource)")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
            }

            detail("One of several", reference.context)
            detail("Modern parallel", reference.modernParallel)
            detail("What this does not mean", reference.caveat)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(QuietSpacing.standard)
        .quietCard()
        .accessibilityIdentifier("provenance.card")
    }

    /// Classical source at one end, modern parallel at the other, the practice
    /// between them. One line, three labels, no ornament.
    private var lineageStrip: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Circle().frame(width: 5, height: 5)
                Rectangle().frame(height: 1)
                Circle().frame(width: 7, height: 7)
                Rectangle().frame(height: 1)
                Circle().frame(width: 5, height: 5)
            }
            .foregroundStyle(Color.quietInk.opacity(0.35))

            HStack {
                Text("Classical source")
                Spacer()
                Text("This practice")
                Spacer()
                Text("Current research")
            }
            .font(.caption2)
            .foregroundStyle(Color.quietInk.opacity(0.55))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lineage: classical source, this practice, current research")
    }

    private func detail(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.quietInk.opacity(0.6))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.quietInk.opacity(0.85))
        }
    }
}
